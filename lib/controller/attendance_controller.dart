import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/model/attendance_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';

class AttendanceController extends GetxController {
  TextEditingController programNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  RxList<Volunteer> usersList = <Volunteer>[].obs;
  RxList<Volunteer> searchList = <Volunteer>[].obs;
  RxList<Volunteer> selectedVolList = <Volunteer>[].obs;
  RxList<Attendance> attendanceList = <Attendance>[].obs;
  RxList<Program> programsList = <Program>[].obs;
  RxInt sortColumnIndex = 0.obs;
  RxBool isAscending = true.obs;

  int? programId;
  RxBool isLoading = false.obs;
  RxBool isDeleteButtonLoading = false.obs;
  RxBool isAttendanceLoading = false.obs;

  RxBool isProgramLoading = true.obs;
  RxInt totalHours = 0.obs;
  RxInt totalPrograms = 0.obs;
  DateTime? date;

  @override
  void onInit() {
    getUsers();
    getPrograms();

    super.onInit();
  }

  void getUsers() {
    isLoading.value = true;
    Api().getVolunteers().then((value) {
      final data = value?.data
          ?.where((element) => element.role != 'po')
          .toList();
      usersList.assignAll(data ?? []);
      searchList.assignAll(usersList);
      searchList.sort((a, b) => a.name!.compareTo(b.name!));
      isLoading.value = false;
    });
  }

  Future<void> getPrograms() async {
    isProgramLoading.value = true;

    try {
      final value = await Api().programNames();
      programsList.assignAll(value?.programs ?? []);
    } catch (e) {
      log('Error loading programs: $e');
    } finally {
      isProgramLoading.value = false;
    }
  }

  Future<void> getAttendance(String id) async {
    isAttendanceLoading.value = true;
    return Api().getAttendance(id).then((value) {
      attendanceList.assignAll(value?.attendance ?? []);
      attendanceList.sort((a, b) => b.date!.compareTo(a.date!));
      isLoading.value = false;
      isAttendanceLoading.value = false;

      totalHours.value = attendanceList.fold(
        0,
        (sum, element) => (sum += element.hours ?? 0),
      );
      totalPrograms.value = attendanceList.length;
    });
  }

  bool onSubmitAttendanceValidation() {
    if (programId == null) {
      CustomWidgets.showSnackBar('Invalid', 'Please select a valid program ');
      return false;
    }
    if (dateController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter date');
      return false;
    }
    if (durationController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter duration');
      return false;
    }
    if (selectedVolList.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please select volunteers');
      return false;
    }
    return true;
  }

  onSubmitAttendance() async {
    isLoading.value = true;
    bool response = true;
    for (Volunteer e in selectedVolList) {
      final value = await Api().addAttendance({
        'date': date.toString(),
        'hours': int.tryParse(durationController.text),
        'program': programId,
        'volunteer': e.admissionNo.toString(),
      });
      if (!(value?.status ?? true)) response = false;
    }

    isLoading.value = false;
    if (response) {
      Get.back();
      Get.back();
      CustomWidgets.showSnackBar('Success', 'Attendance added successfully');
    } else {
      CustomWidgets.showSnackBar('Error', 'Some attendance not added');
    }
  }

  deleteAttendance(int id) async {
    isDeleteButtonLoading.value = true;
    Api().deleteAttendance(id).then((value) {
      isDeleteButtonLoading.value = false;
      if (value?.status ?? false) {
        Get.back();
        CustomWidgets.showSnackBar(
          "Success",
          value?.message ?? "Attendance deleted successfully.",
        );
      } else {
        CustomWidgets.showSnackBar(
          "Error",
          value?.message ?? 'Failed to delete attendance.',
        );
      }
    });
  }

  void onSearchTextChanged(String value) async {
    if (value.isEmpty) {
      searchController.clear();
      searchList.assignAll(usersList);
    } else {
      final filtered = usersList.where((volunteer) {
        final name = volunteer.name?.toLowerCase() ?? '';
        final admnNo = volunteer.admissionNo ?? '';

        return admnNo.contains(value.toLowerCase()) || name.contains(value);
      }).toList();

      searchList.assignAll(filtered);
    }
  }
}
