import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/enrollment_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/view/students_enrollment_screen.dart';

class ProgramListController extends GetxController {
  final Api _api = Api();

  RxList<Program> programsList = <Program>[].obs;
  RxList<Program> searchList = <Program>[].obs;
  RxBool isLoading = false.obs;
  RxBool isButtonLoading = false.obs;
  final RxBool isCheckingEnrollment = true.obs;

  final RxSet<int> enrollingProgramIds = <int>{}.obs;
  final RxSet<int> cancellingProgramIds = <int>{}.obs;
  final RxSet<int> loadingEnrollmentProgramIds = <int>{}.obs;
  final RxSet<int> verifiedProgramEnrollmentIds = <int>{}.obs;
  final RxMap<int, DateTime> enrolledPrograms = <int, DateTime>{}.obs;

  TextEditingController searchController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  RxString date = 'newest'.obs;
  RxString selectedStatusFilter = ''.obs; // 'upcoming', 'past', or ''

  RxList<ProgramEnrollmentDetails> enrollmentList =
      <ProgramEnrollmentDetails>[].obs;
  RxList<Volunteer> selectedVolList = <Volunteer>[].obs;

  DateTime programDate = DateTime.now();
  RxString showProgramDate = ''.obs;

  @override
  void onReady() {
    super.onReady();
    loadVolunteerEnrollments();
    getPrograms();
  }

  void resetEnrollmentState() {
    enrolledPrograms.clear();
    verifiedProgramEnrollmentIds.clear();
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

  @override
  void onClose() {
    searchController.dispose();
    durationController.dispose();
    super.onClose();
  }

  void selectAllVolunteers() {
    selectedVolList.clear();
    for (ProgramEnrollmentDetails vol in enrollmentList) {
      if (vol.volunteer != null) {
        selectedVolList.add(vol.volunteer!);
      }
    }
  }

  void getPrograms({String? status}) async {
    if (isClosed) return;
    isLoading.value = true;
    if (status != null) selectedStatusFilter.value = status;

    loadVolunteerEnrollments();

    _api
        .allPrograms(
          search: searchController.text,
          status: selectedStatusFilter.value,
        )
        .then((value) {
          if (isClosed) return;
          programsList.assignAll(value?.programs ?? []);
          for (final p in programsList) {
            if (p.id != null) {
              verifiedProgramEnrollmentIds.add(p.id!);
            }
          }
          _applySearchAndSort();
          isLoading.value = false;
          isCheckingEnrollment.value = false;
        })
        .catchError((_) {
          if (!isClosed) {
            isLoading.value = false;
            isCheckingEnrollment.value = false;
          }
        });
  }

  void getUpcomingPrograms() async {
    if (isClosed) return;
    isLoading.value = true;
    selectedStatusFilter.value = 'upcoming';

    loadVolunteerEnrollments();

    _api
        .getUpcomingPrograms()
        .then((value) {
          if (isClosed) return;
          programsList.assignAll(value?.programs ?? []);
          for (final p in programsList) {
            if (p.id != null) {
              verifiedProgramEnrollmentIds.add(p.id!);
            }
          }
          _applySearchAndSort();
          isLoading.value = false;
          isCheckingEnrollment.value = false;
        })
        .catchError((_) {
          if (!isClosed) {
            isLoading.value = false;
            isCheckingEnrollment.value = false;
          }
        });
  }

  Future<void> enrollInProgram(
    int programId, {
    String? volunteerAdmissionNo,
  }) async {
    if (isClosed) return;
    if (enrollingProgramIds.contains(programId) ||
        cancellingProgramIds.contains(programId)) {
      return;
    }
    enrollingProgramIds.add(programId);
    isButtonLoading.value = true;

    final user = LocalStorage().readUser();
    final admissionNo = volunteerAdmissionNo ?? user.admissionNo ?? '';

    final map = <String, dynamic>{'program': programId, 'id': programId};
    if (volunteerAdmissionNo != null && volunteerAdmissionNo.isNotEmpty) {
      map['volunteer'] = volunteerAdmissionNo;
    }

    try {
      final res = await _api.enrollToProgram(map);
      if (isClosed) return;

      final nowServer = LocalStorage().getEstimatedServerTime();
      if (res?.status ?? false) {
        if (admissionNo.isNotEmpty) {
          LocalStorage().saveVolunteerEnrollment(
            admissionNo,
            programId,
            nowServer,
          );
        }
        enrolledPrograms[programId] = nowServer;
        CustomWidgets.showSnackBar(
          'Success',
          res?.message ?? 'Enrolled successfully',
        );
        getPrograms();
      } else {
        final msg = res?.message ?? 'Failed to enroll';
        if (msg.toLowerCase().contains('already enrolled')) {
          if (admissionNo.isNotEmpty) {
            LocalStorage().saveVolunteerEnrollment(
              admissionNo,
              programId,
              nowServer,
            );
          }
          enrolledPrograms[programId] = nowServer;
          CustomWidgets.showSnackBar('Notice', msg);
        } else {
          CustomWidgets.showSnackBar('Error', msg);
        }
      }
    } catch (e) {
      if (!isClosed) {
        CustomWidgets.showSnackBar('Error', 'Enrollment failed: $e');
      }
    } finally {
      if (!isClosed) {
        enrollingProgramIds.remove(programId);
        isButtonLoading.value =
            enrollingProgramIds.isNotEmpty || cancellingProgramIds.isNotEmpty;
      }
    }
  }

  Future<void> cancelEnrollment(
    int programId, {
    String? volunteerAdmissionNo,
  }) async {
    if (isClosed) return;
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
    isButtonLoading.value = true;

    final user = LocalStorage().readUser();
    final admissionNo = volunteerAdmissionNo ?? user.admissionNo ?? '';

    try {
      final res = await _api.cancelEnrollment(
        programId,
        volunteer: volunteerAdmissionNo,
      );
      if (isClosed) return;

      if (res?.status ?? false) {
        if (admissionNo.isNotEmpty) {
          LocalStorage().removeVolunteerEnrollment(admissionNo, programId);
        }
        enrolledPrograms.remove(programId);
        CustomWidgets.showSnackBar(
          'Success',
          res?.message ?? 'Enrollment cancelled',
        );
        getPrograms();
      } else {
        final msg = res?.message ?? 'Failed to cancel enrollment';
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
        isButtonLoading.value =
            cancellingProgramIds.isNotEmpty || enrollingProgramIds.isNotEmpty;
      }
    }
  }

  void addAttendance(Program? program) async {
    if (program?.id == null || isClosed) return;
    isLoading.value = true;
    int hours = int.tryParse(durationController.text) ?? program?.duration ?? 0;

    List<Map<String, dynamic>> attendances = selectedVolList
        .map((v) => {'volunteer': v.admissionNo, 'hours': hours})
        .toList();

    _api
        .bulkAddAttendance(program!.id!, attendances)
        .then((val) {
          if (isClosed) return;
          isLoading.value = false;
          if (val?.status ?? false) {
            Get.back();
            Get.back();
            CustomWidgets.showSnackBar(
              'Success',
              'Attendance recorded successfully',
            );
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              val?.message ?? 'Failed to record attendance',
            );
          }
        })
        .catchError((_) {
          if (!isClosed) isLoading.value = false;
        });
  }

  void getEnrolledStudents(Program? program, [RxBool? loading]) async {
    final programId = program?.id;
    if (programId == null || isClosed) return;
    if (loadingEnrollmentProgramIds.contains(programId)) return;

    loadingEnrollmentProgramIds.add(programId);
    if (loading != null) loading.value = true;

    _api
        .getEnrolledStudents(programId)
        .then((value) {
          if (isClosed) return;
          enrollmentList.assignAll(value?.enrollmentList?.toList() ?? []);
          selectAllVolunteers();
          durationController.text = "${program?.duration ?? 0}";
          programDate = program?.date ?? DateTime.now();
          showProgramDate.value = DateFormat.yMMMd().format(programDate);

          loadingEnrollmentProgramIds.remove(programId);
          if (loading != null) loading.value = false;
          Get.to(() => StudentsEnrollmentScreen(data: program));
        })
        .catchError((_) {
          if (!isClosed) {
            loadingEnrollmentProgramIds.remove(programId);
            if (loading != null) loading.value = false;
          }
        });
  }

  void removeProgramLocally(int id) {
    if (isClosed) return;
    programsList.removeWhere((p) => p.id == id);
    searchList.removeWhere((p) => p.id == id);
    _applySearchAndSort();
  }

  void updateProgramLocally(Program updated) {
    if (isClosed) return;
    final index = programsList.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      final old = programsList[index];
      updated.enrollmentCount = old.enrollmentCount;
      updated.createdBy = old.createdBy;
      programsList[index] = updated;
      _applySearchAndSort();
    }
  }

  void addProgramLocally(Program program) {
    if (isClosed) return;
    programsList.insert(0, program);
    _applySearchAndSort();
  }

  void onSearchTextChanged(String searchText) {
    if (isClosed) return;
    _applySearchAndSort();
  }

  void _applySearchAndSort() {
    if (isClosed) return;
    final query = searchController.text.toLowerCase();
    List<Program> filtered = [];

    if (query.isEmpty) {
      filtered = List.from(programsList);
    } else {
      filtered = programsList
          .where((p) => (p.name?.toLowerCase() ?? '').contains(query))
          .toList();
    }

    if (date.value == 'oldest') {
      filtered.sort(
        (a, b) =>
            (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()),
      );
    } else {
      filtered.sort(
        (a, b) =>
            (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()),
      );
    }

    searchList.assignAll(filtered);
  }

  void sortByDate() {
    if (isClosed) return;
    date.value = (date.value == 'oldest') ? 'newest' : 'oldest';
    _applySearchAndSort();
  }
}

class AddProgramController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController limitController = TextEditingController();

  var isUpdateButtonLoading = false.obs;
  var isDeleteButtonLoading = false.obs;
  DateTime? date;

  @override
  void onClose() {
    nameController.dispose();
    dateController.dispose();
    descController.dispose();
    durationController.dispose();
    limitController.dispose();
    super.onClose();
  }

  void addProgram() {
    if (isClosed) return;
    isUpdateButtonLoading.value = true;
    final programData = Program(
      name: nameController.text.trim(),
      date: date,
      duration: int.tryParse(durationController.text.trim()) ?? 0,
      limit: int.tryParse(limitController.text.trim()) ?? 0,
      description: descController.text.trim(),
    );
    Api()
        .addProgram(programData)
        .then((value) {
          if (isClosed) return;
          isUpdateButtonLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            if (Get.isRegistered<ProgramListController>()) {
              Get.find<ProgramListController>().getPrograms();
            }
            CustomWidgets.showSnackBar(
              "Success",
              value?.message ?? "Program added successfully",
            );
          } else {
            CustomWidgets.showSnackBar(
              "Error",
              value?.message ?? 'Failed to add program.',
            );
          }
        })
        .catchError((_) {
          if (!isClosed) isUpdateButtonLoading.value = false;
        });
  }

  void updateProgram(int id) {
    if (isClosed) return;
    isUpdateButtonLoading.value = true;
    final updatedProgram = Program(
      id: id,
      name: nameController.text.trim(),
      date: date,
      duration: int.tryParse(durationController.text.trim()) ?? 0,
      limit: int.tryParse(limitController.text.trim()) ?? 0,
      description: descController.text.trim(),
    );
    Api()
        .updateProgram({
          'id': id,
          'name': nameController.text.trim(),
          'date': date?.toIso8601String() ?? dateController.text,
          'duration': durationController.text.trim(),
          'limit': int.tryParse(limitController.text.trim()) ?? 0,
          'description': descController.text.trim(),
        })
        .then((value) {
          if (isClosed) return;
          isUpdateButtonLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            if (Get.isRegistered<ProgramListController>()) {
              Get.find<ProgramListController>().updateProgramLocally(
                updatedProgram,
              );
            }
            CustomWidgets.showSnackBar(
              "Success",
              value?.message ?? "Program updated successfully.",
            );
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              value?.message ?? 'Failed to update program.',
            );
          }
        })
        .catchError((_) {
          if (!isClosed) isUpdateButtonLoading.value = false;
        });
  }

  Future<void> deleteProgram(int id) async {
    if (isClosed) return;
    isDeleteButtonLoading.value = true;
    try {
      final value = await Api().deleteProgram(id);
      if (isClosed) return;
      if (value?.status == true) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        if (Get.isRegistered<ProgramListController>()) {
          Get.find<ProgramListController>().removeProgramLocally(id);
        }
        CustomWidgets.showSnackBar(
          "Success",
          value?.message ?? "Program deleted successfully.",
        );
      } else {
        CustomWidgets.showSnackBar(
          "Error",
          value?.message ?? "Failed to delete program.",
        );
      }
    } catch (e) {
      CustomWidgets.showSnackBar("Error", e.toString());
    } finally {
      if (!isClosed) {
        isDeleteButtonLoading.value = false;
      }
    }
  }

  bool onSubmitProgramValidation() {
    if (nameController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter program name');
      return false;
    }
    if (date == null && dateController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please select date');
      return false;
    }
    if (durationController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter duration');
      return false;
    }
    return true;
  }

  void setUpdateData(Program program) {
    nameController.text = program.name ?? '';
    descController.text = program.description ?? '';
    date = program.date;
    dateController.text = (program.date != null)
        ? DateFormat.yMMMd().format(program.date!)
        : '';
    durationController.text = (program.duration != null)
        ? program.duration.toString()
        : '';
    limitController.text = (program.limit != null)
        ? program.limit.toString()
        : '0';
  }

  void clearTextFields() {
    nameController.clear();
    durationController.clear();
    descController.clear();
    dateController.clear();
    limitController.clear();
    date = null;
  }
}
