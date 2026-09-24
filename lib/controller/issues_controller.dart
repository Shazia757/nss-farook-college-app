import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/issues_model.dart';
import 'package:nss_new/model/volunteer_model.dart';

class IssuesController extends GetxController with GetTickerProviderStateMixin {
  final Api _api = Api();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController resolvedByController = TextEditingController();

  RxString submittedTo = 'sec'.obs;
  RxBool isLoading = false.obs;
  RxBool isReportLoading = false.obs;
  RxBool isResolveLoading = false.obs;
  RxString resolvedByAdmID = ''.obs;

  RxList<Volunteer?> adminList = <Volunteer?>[].obs;
  late TabController tabController;
  List<Issues> openedList = [];
  List<Issues> closedList = [];
  RxList<Issues> modifiedOpenedList = <Issues>[].obs;
  RxList<Issues> modifiedClosedList = <Issues>[].obs;
  RxString reportedTo = 'both'.obs;
  RxBool sortByOldest = true.obs;
  late TabController adminTabController;
  RxBool isResolved = false.obs;

  void filterByRole(String assignedTo) {
    reportedTo.value = assignedTo;
    _openFilteredTo();
    _closedFilteredTo();
  }

  void _openFilteredTo() {
    if (reportedTo.value == "all" || reportedTo.value == "both") {
      modifiedOpenedList.assignAll(openedList);
    } else {
      modifiedOpenedList.assignAll(
        openedList.where((p0) => p0.to == reportedTo.value).toList(),
      );
    }
  }

  void _closedFilteredTo() {
    if (reportedTo.value == "all" || reportedTo.value == "both") {
      modifiedClosedList.assignAll(closedList);
    } else {
      modifiedClosedList.assignAll(
        closedList.where((p0) => p0.to == reportedTo.value).toList(),
      );
    }
  }

  void resolvedBy(String? admID) {
    resolvedByAdmID.value = admID ?? '';
    modifiedClosedList.assignAll(
      closedList.where((e) => e.updatedBy == admID).toList(),
    );
  }

  void sortByOldestDate(bool isOldest) {
    sortByOldest.value = isOldest;
    _sortOpenedList();
    _sortClosedList();
  }

  void _sortOpenedList() {
    if (sortByOldest.isTrue) {
      modifiedOpenedList.sort(
        (a, b) => (a.createdDate ?? DateTime.now()).compareTo(
          b.createdDate ?? DateTime.now(),
        ),
      );
    } else {
      modifiedOpenedList.sort(
        (a, b) => (b.createdDate ?? DateTime.now()).compareTo(
          a.createdDate ?? DateTime.now(),
        ),
      );
    }
  }

  void _sortClosedList() {
    if (sortByOldest.isTrue) {
      modifiedClosedList.sort(
        (a, b) => (a.createdDate ?? DateTime.now()).compareTo(
          b.createdDate ?? DateTime.now(),
        ),
      );
    } else {
      modifiedClosedList.sort(
        (a, b) => (b.createdDate ?? DateTime.now()).compareTo(
          a.createdDate ?? DateTime.now(),
        ),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    adminTabController = TabController(length: 2, vsync: this);
  }

  @override
  void onReady() {
    super.onReady();
    getAdmins();
    fetchIssues();
  }

  @override
  void onClose() {
    tabController.dispose();
    adminTabController.dispose();
    subjectController.dispose();
    desController.dispose();
    toController.dispose();
    resolvedByController.dispose();
    super.onClose();
  }

  void clearIssues() {
    openedList.clear();
    closedList.clear();
    modifiedOpenedList.clear();
    modifiedClosedList.clear();
  }

  Future<void> fetchIssues() async {
    if (isClosed) return;
    final user = LocalStorage().readUser();
    if (user.role != 'vol') {
      await getAdminIssues();
    } else {
      await getVolIssues(user.admissionNo ?? '');
    }
  }

  void getAdmins() {
    if (isClosed) return;
    _api
        .getAdmins()
        .then((value) {
          if (isClosed) return;
          adminList.assignAll(value?.data ?? []);
        })
        .catchError((_) {});
  }

  Future<void> getAdminIssues() async {
    if (isClosed) return;
    clearIssues();
    isLoading.value = true;
    try {
      final value = await _api.getAdminIssues();
      if (isClosed) return;
      openedList = value?.openIssues ?? [];
      closedList = value?.closedIssues ?? [];
      modifiedOpenedList.assignAll(openedList);
      modifiedClosedList.assignAll(closedList);
      _openFilteredTo();
      _closedFilteredTo();
      _sortOpenedList();
      _sortClosedList();
    } catch (e) {
      log('Error fetching admin issues: $e');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> getVolIssues(String admissionNo) async {
    if (isClosed) return;
    clearIssues();
    isLoading.value = true;
    try {
      final value = await _api.getVolIssues(admissionNo);
      if (isClosed) return;
      openedList = value?.openIssues ?? [];
      closedList = value?.closedIssues ?? [];
      modifiedOpenedList.assignAll(openedList);
      modifiedClosedList.assignAll(closedList);
      _sortOpenedList();
      _sortClosedList();
    } catch (e) {
      log('Error fetching volunteer issues: $e');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  void reportIssue() {
    if (!onSubmitIssueValidation() || isClosed) return;
    isReportLoading.value = true;
    _api
        .addIssue({
          'subject': subjectController.text,
          'description': desController.text,
          'assigned_to': submittedTo.value,
        })
        .then((value) {
          if (isClosed) return;
          isReportLoading.value = false;
          Get.back();
          if (value?.status ?? false) {
            subjectController.clear();
            desController.clear();
            CustomWidgets.showSnackBar(
              "Success",
              value?.message ?? "Issue reported successfully",
              backgroundColor: Colors.green.shade800,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            );
            fetchIssues();
          } else {
            CustomWidgets.showSnackBar(
              "Error",
              value?.message ?? 'Failed to report issue.',
              backgroundColor: Colors.red.shade800,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        })
        .catchError((_) {
          if (!isClosed) {
            isReportLoading.value = false;
            Get.back();
            CustomWidgets.showSnackBar(
              "Error",
              'Failed to report issue.',
              backgroundColor: Colors.red.shade800,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        });
  }

  void resolveIssue(int? id) {
    if (id == null || isClosed) return;
    isResolveLoading.value = true;
    _api
        .resolveIssue({'id': id})
        .then((value) {
          if (isClosed) return;
          isResolveLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            CustomWidgets.showSnackBar(
              "Success",
              value?.message ?? "Issue resolved successfully.",
            );
            fetchIssues();
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              value?.message ?? 'Failed to resolve issue.',
            );
          }
        })
        .catchError((_) {
          if (!isClosed) isResolveLoading.value = false;
        });
  }

  void deleteIssue(int? id) {
    if (id == null || isClosed) return;
    isLoading.value = true;
    _api
        .deleteIssue(id)
        .then((value) {
          if (isClosed) return;
          isLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            CustomWidgets.showSnackBar(
              "Success",
              value?.message ?? "Issue deleted successfully.",
            );
            fetchIssues();
          } else {
            CustomWidgets.showSnackBar(
              "Error",
              value?.message ?? "Failed to delete issue.",
            );
          }
        })
        .catchError((_) {
          if (!isClosed) isLoading.value = false;
        });
  }

  bool onSubmitIssueValidation() {
    if (subjectController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please select an issue type',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    if (desController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please enter issue description',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    return true;
  }
}
