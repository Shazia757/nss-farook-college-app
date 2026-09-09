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
      modifiedOpenedList.sort((a, b) => (a.createdDate ?? DateTime.now()).compareTo(b.createdDate ?? DateTime.now()));
    } else {
      modifiedOpenedList.sort((a, b) => (b.createdDate ?? DateTime.now()).compareTo(a.createdDate ?? DateTime.now()));
    }
  }

  void _sortClosedList() {
    if (sortByOldest.isTrue) {
      modifiedClosedList.sort((a, b) => (a.createdDate ?? DateTime.now()).compareTo(b.createdDate ?? DateTime.now()));
    } else {
      modifiedClosedList.sort((a, b) => (b.createdDate ?? DateTime.now()).compareTo(a.createdDate ?? DateTime.now()));
    }
  }

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    adminTabController = TabController(length: 2, vsync: this);
    getAdmins();
    fetchIssues();
    super.onInit();
  }

  void fetchIssues() {
    final user = LocalStorage().readUser();
    if (user.role != 'vol') {
      getAdminIssues();
    } else {
      getVolIssues(user.admissionNo ?? '');
    }
  }

  void getAdmins() {
    _api.getAdmins().then((value) => adminList.assignAll(value?.data ?? []));
  }

  Future<void> getAdminIssues() async {
    isLoading.value = true;
    final value = await _api.getAdminIssues();
    openedList = value?.openIssues ?? [];
    closedList = value?.closedIssues ?? [];
    modifiedOpenedList.assignAll(openedList);
    modifiedClosedList.assignAll(closedList);
    _sortOpenedList();
    _sortClosedList();
    isLoading.value = false;
  }

  Future<void> getVolIssues(String admissionNo) async {
    isLoading.value = true;
    final value = await _api.getVolIssues(admissionNo);
    openedList = value?.openIssues ?? [];
    closedList = value?.closedIssues ?? [];
    modifiedOpenedList.assignAll(openedList);
    modifiedClosedList.assignAll(closedList);
    _sortOpenedList();
    _sortClosedList();
    isLoading.value = false;
  }

  void reportIssue() {
    if (!onSubmitIssueValidation()) return;
    isReportLoading.value = true;
    _api
        .addIssue({
          'subject': subjectController.text,
          'description': desController.text,
          'assigned_to': submittedTo.value,
        })
        .then((value) {
          isReportLoading.value = false;
          Get.back();
          if (value?.status ?? false) {
            subjectController.clear();
            desController.clear();
            CustomWidgets.showSnackBar(
              "Success",
              value?.message ?? "Issue reported successfully",
            );
            fetchIssues();
          } else {
            CustomWidgets.showSnackBar(
              "Error",
              value?.message ?? 'Failed to report issue.',
            );
          }
        });
  }

  void resolveIssue(int? id) {
    if (id == null) return;
    isResolveLoading.value = true;
    _api
        .resolveIssue({'id': id})
        .then((value) {
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
        });
  }

  void deleteIssue(int? id) {
    if (id == null) return;
    isLoading.value = true;
    _api.deleteIssue(id).then((value) {
      isLoading.value = false;
      if (value?.status ?? false) {
        Get.back();
        CustomWidgets.showSnackBar("Success", value?.message ?? "Issue deleted successfully.");
        fetchIssues();
      } else {
        CustomWidgets.showSnackBar("Error", value?.message ?? "Failed to delete issue.");
      }
    });
  }

  bool onSubmitIssueValidation() {
    if (subjectController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter subject');
      return false;
    }
    if (desController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please add description');
      return false;
    }
    return true;
  }
}
