import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/issues_model.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';

class IssuesController extends GetxController with GetTickerProviderStateMixin {
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
    if (reportedTo.value == "all") {
      modifiedOpenedList.assignAll(openedList);
    } else {
      modifiedOpenedList.assignAll(
        openedList.where((p0) => p0.to == reportedTo.value).toList(),
      );
    }
  }

  void _closedFilteredTo() {
    if (reportedTo.value == "all") {
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
    (sortByOldest.isTrue)
        ? modifiedOpenedList.sort(
            (a, b) => a.createdDate!.compareTo(b.createdDate!),
          )
        : modifiedOpenedList.sort(
            (a, b) => b.createdDate!.compareTo(a.createdDate!),
          );
  }

  void _sortClosedList() {
    (sortByOldest.isTrue)
        ? modifiedClosedList.sort(
            (a, b) => a.createdDate!.compareTo(b.createdDate!),
          )
        : modifiedClosedList.sort(
            (a, b) => b.createdDate!.compareTo(a.createdDate!),
          );
  }

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    adminTabController = TabController(length: 2, vsync: this);
    getAdmins();
    (LocalStorage().readUser().role != 'vol')
        ? getAdminIssues()
        : getVolIssues(LocalStorage().readUser().admissionNo ?? '');

    super.onInit();
  }

  getAdmins() {
    Api().getAdmins().then((value) => adminList.assignAll(value?.data ?? []));
  }

  getAdminIssues() {
    isLoading.value = true;
    Api().getAdminIssues().then((value) {
      openedList = value?.openIssues ?? [];
      closedList = value?.closedIssues ?? [];
      modifiedOpenedList.assignAll(openedList);
      modifiedClosedList.assignAll(closedList);
      modifiedOpenedList.sort(
        (a, b) => b.createdDate!.compareTo(a.createdDate!),
      );
      modifiedClosedList.sort(
        (a, b) => b.createdDate!.compareTo(a.createdDate!),
      );

      isLoading.value = false;
    });
  }

  void getVolIssues(String admissionNo) {
    isLoading.value = true;

    Api().getVolIssues(admissionNo).then((value) {
      openedList = value?.openIssues ?? [];
      closedList = value?.closedIssues ?? [];
      modifiedOpenedList.assignAll(openedList);

      modifiedClosedList.assignAll(closedList);
      modifiedOpenedList.sort(
        (a, b) => b.createdDate!.compareTo(a.createdDate!),
      );
      modifiedClosedList.sort(
        (a, b) => b.createdDate!.compareTo(a.createdDate!),
      );

      isLoading.value = false;
    });
  }

  void reportIssue() {
    isReportLoading.value = true;
    Api()
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
          } else {
            CustomWidgets.showSnackBar(
              "Error",
              value?.message ?? 'Failed to report issue.',
            );
          }
        })
        .then((value) => onInit());
  }

  void resolveIssue(int? id) {
    isLoading.value = true;
    Api()
        .resolveIssue({'id': id})
        .then((value) {
          isLoading.value = false;
          Get.back();
          if (value?.status ?? false) {
            Get.back();

            CustomWidgets.showSnackBar(
              "Success",
              value?.message ?? "Issue resolved successfully.",
            );
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              value?.message ?? 'Failed to resolve issue.',
            );
          }
        })
        .then((value) => onInit());
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
