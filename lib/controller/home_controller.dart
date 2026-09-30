import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/volunteer_model.dart';

class HomeController extends GetxController {
  final Api _api = Api();

  RxList<Program> upcomingPrograms = <Program>[].obs;
  RxList<BloodDonationRequest> openBloodRequests = <BloodDonationRequest>[].obs;
  Rxn<VolunteerHoursSummary> hoursSummary = Rxn<VolunteerHoursSummary>();

  RxBool isLoading = true.obs;
  RxBool isEnrolledLoading = false.obs;
  final RxBool isCheckingEnrollment = true.obs;

  final RxSet<int> enrollingProgramIds = <int>{}.obs;
  final RxSet<int> cancellingProgramIds = <int>{}.obs;
  final RxSet<int> verifiedProgramEnrollmentIds = <int>{}.obs;
  final RxMap<int, DateTime> enrolledPrograms = <int, DateTime>{}.obs;

  @override
  void onReady() {
    super.onReady();
    loadVolunteerEnrollments();
    refreshDashboard();
  }

  void resetEnrollmentState() {
    enrolledPrograms.clear();
    enrollingProgramIds.clear();
    cancellingProgramIds.clear();
    isCheckingEnrollment.value = true;
  }

  void loadVolunteerEnrollments() {
    final user = LocalStorage().readUser();
    final admn = user.admissionNo;
    if (admn != null && admn.isNotEmpty) {
      final saved = LocalStorage().getVolunteerEnrollments(admn);
      enrolledPrograms.assignAll(saved);
    } else {
      enrolledPrograms.clear();
    }
  }

  bool isEnrollmentVerified(int programId) {
    return !isCheckingEnrollment.value &&
        verifiedProgramEnrollmentIds.contains(programId);
  }

  bool isEnrolled(int programId) {
    return enrolledPrograms.containsKey(programId);
  }

  DateTime? getEnrollmentTimestamp(int programId) {
    return enrolledPrograms[programId];
  }

  bool canCancelEnrollment(int programId) {
    if (!isEnrolled(programId)) return false;
    final enrolledAt = enrolledPrograms[programId];
    if (enrolledAt == null) return false;
    final currentServerTime = LocalStorage().getEstimatedServerTime();
    final diff = currentServerTime.difference(enrolledAt);
    return diff.inHours < 24 && !diff.isNegative;
  }

  Duration? getRemainingCancellationDuration(int programId) {
    final enrolledAt = enrolledPrograms[programId];
    if (enrolledAt == null) return null;
    final currentServerTime = LocalStorage().getEstimatedServerTime();
    final diff = currentServerTime.difference(enrolledAt);
    final remaining = const Duration(hours: 24) - diff;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String getRemainingCancellationText(int programId) {
    final remaining = getRemainingCancellationDuration(programId);
    if (remaining == null || remaining == Duration.zero) {
      return 'Cancellation window expired';
    }
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min ' : ''}left to cancel';
    }
    return '$minutes min left to cancel';
  }

  void refreshDashboard() async {
    if (isClosed) return;
    isLoading.value = true;
    try {
      await Future.wait([
        fetchUpcomingPrograms(),
        fetchOpenBloodRequests(),
        fetchVolunteerHours(),
      ]);
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> syncVolunteerEnrollments() async {
    if (isClosed) return;

    final user = LocalStorage().readUser();

    if (user.role != 'vol') return;

    isCheckingEnrollment.value = true;

    try {
      final res = await _api.getVolunteerUpcomingEnrollments();

      if (isClosed) return;

      if (res?.status == true) {
        final serverEnrollments = <int, DateTime>{};

        for (final enrollment in res?.programs ?? []) {
          final programId = enrollment.program.id;

          if (programId == null) continue;

          final enrollmentDate =
              enrollment.enrollmentDate ??
              LocalStorage().getEstimatedServerTime();

          serverEnrollments[programId] = enrollmentDate;

          if (user.admissionNo != null && user.admissionNo!.isNotEmpty) {
            LocalStorage().saveVolunteerEnrollment(
              user.admissionNo!,
              programId,
              enrollmentDate,
            );
          }
        }

        enrolledPrograms.assignAll(serverEnrollments);

        // The API request completed successfully.
        // We have verified the enrollment state from the server.
        isCheckingEnrollment.value = false;
      }
    } catch (e) {
      log('Volunteer enrollment sync failed: $e');

      // Keep the locally cached enrollment state if the API fails.
    } finally {
      if (!isClosed) {
        isCheckingEnrollment.value = false;
      }
    }
  }

  Future<void> fetchUpcomingPrograms() async {
    if (isClosed) return;
    loadVolunteerEnrollments();
    try {
      final value = await _api.getUpcomingPrograms();
      if (isClosed) return;
      if (value?.programs != null) {
        upcomingPrograms.assignAll(value!.programs!);
        upcomingPrograms.sort(
          (a, b) =>
              (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()),
        );
        await syncVolunteerEnrollments();
      }
    } finally {
      if (!isClosed) {
        isCheckingEnrollment.value = false;
      }
    }
  }

  Future<void> fetchOpenBloodRequests() async {
    if (isClosed) return;
    final requests = await _api.getBloodRequests(status: 'open');
    if (isClosed) return;
    if (requests != null) {
      openBloodRequests.assignAll(requests);
    }
  }

  Future<void> fetchVolunteerHours() async {
    if (isClosed) return;
    final user = LocalStorage().readUser();
    if (user.admissionNo != null && user.admissionNo!.isNotEmpty) {
      final summary = await _api.getVolunteerHoursSummary(
        admissionNumber: user.admissionNo,
      );
      if (isClosed) return;
      if (summary != null) {
        hoursSummary.value = summary;
      }
    }
  }

  Future<void> enroll(Program program) async {
    final programId = program.id;
    if (programId == null || isClosed) return;
    if (enrollingProgramIds.contains(programId) ||
        cancellingProgramIds.contains(programId)) {
      return;
    }

    if (program.limit != null &&
        program.limit! > 0 &&
        (program.enrollmentCount ?? 0) >= program.limit!) {
      CustomWidgets.showSnackBar(
        'Limit Exceeded',
        'Limit exceeded. Cannot enroll in this program.',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }

    enrollingProgramIds.add(programId);
    isEnrolledLoading.value = true;

    final user = LocalStorage().readUser();
    final admissionNo = user.admissionNo ?? '';

    try {
      final response = await _api.enrollToProgram({
        'program': programId,
        'id': programId,
      });
      if (isClosed) return;

      final nowServer = LocalStorage().getEstimatedServerTime();
      if (response?.status == true) {
        if (admissionNo.isNotEmpty) {
          LocalStorage().saveVolunteerEnrollment(
            admissionNo,
            programId,
            nowServer,
          );
        }
        enrolledPrograms[programId] = nowServer;
        program.enrollmentCount = (program.enrollmentCount ?? 0) + 1;
        verifiedProgramEnrollmentIds.add(programId);
        CustomWidgets.showSnackBar(
          'Success',
          response?.message ?? 'You are enrolled.',
        );
        fetchUpcomingPrograms();
      } else {
        final msg = response?.message ?? 'Failed to enroll.';
        final lowerMsg = msg.toLowerCase();
        if (lowerMsg.contains('already enrolled')) {
          if (admissionNo.isNotEmpty) {
            LocalStorage().saveVolunteerEnrollment(
              admissionNo,
              programId,
              nowServer,
            );
          }
          enrolledPrograms[programId] = nowServer;
          verifiedProgramEnrollmentIds.add(programId);
          CustomWidgets.showSnackBar('Notice', msg);
        } else if (lowerMsg.contains('limit') ||
            lowerMsg.contains('full') ||
            lowerMsg.contains('exceeded') ||
            lowerMsg.contains('capacity') ||
            lowerMsg.contains('maximum')) {
          CustomWidgets.showSnackBar(
            'Limit Exceeded',
            'Limit exceeded. Cannot enroll in this program.',
            backgroundColor: Colors.red.shade800,
            icon: const Icon(Icons.error_outline, color: Colors.white),
          );
        } else {
          CustomWidgets.showSnackBar('Error', msg);
        }
      }
    } catch (e) {
      if (!isClosed) {
        CustomWidgets.showSnackBar('Error', 'Failed to enroll: $e');
      }
    } finally {
      if (!isClosed) {
        enrollingProgramIds.remove(programId);
        isEnrolledLoading.value = enrollingProgramIds.isNotEmpty;
      }
    }
  }

  Future<void> cancelEnrollment(Program program) async {
    final programId = program.id;
    if (programId == null || isClosed) return;
    if (cancellingProgramIds.contains(programId) ||
        enrollingProgramIds.contains(programId)) {
      return;
    }

    if (!canCancelEnrollment(programId)) {
      CustomWidgets.showSnackBar(
        'Cancellation Expired',
        'Cancellation window (24 hours) has passed for this program.',
      );
      return;
    }

    cancellingProgramIds.add(programId);

    final user = LocalStorage().readUser();
    final admissionNo = user.admissionNo ?? '';

    try {
      final response = await _api.cancelEnrollment(programId);
      if (isClosed) return;

      if (response?.status == true) {
        if (admissionNo.isNotEmpty) {
          LocalStorage().removeVolunteerEnrollment(admissionNo, programId);
        }
        enrolledPrograms.remove(programId);
        verifiedProgramEnrollmentIds.add(programId);
        if (program.enrollmentCount != null && program.enrollmentCount! > 0) {
          program.enrollmentCount = program.enrollmentCount! - 1;
        }
        CustomWidgets.showSnackBar(
          'Success',
          response?.message ?? 'Enrollment cancelled.',
        );
        fetchUpcomingPrograms();
      } else {
        final msg = response?.message ?? 'Failed to cancel enrollment.';
        if (msg.toLowerCase().contains('not found')) {
          if (admissionNo.isNotEmpty) {
            LocalStorage().removeVolunteerEnrollment(admissionNo, programId);
          }
          enrolledPrograms.remove(programId);
        }
        CustomWidgets.showSnackBar('Error', msg);
      }
    } catch (e) {
      if (!isClosed) {
        CustomWidgets.showSnackBar('Error', 'Failed to cancel enrollment: $e');
      }
    } finally {
      if (!isClosed) {
        cancellingProgramIds.remove(programId);
      }
    }
  }
}
