import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/model/attendance_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/volunteer_model.dart';

class AttendanceController extends GetxController {
  final Api _api = Api();

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
    _api.getVolunteers().then((value) {
      final data = value?.data?.where((element) => element.role != 'po').toList();
      usersList.assignAll(data ?? []);
      searchList.assignAll(usersList);
      searchList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      isLoading.value = false;
    });
  }

  Future<void> getPrograms() async {
    isProgramLoading.value = true;
    try {
      final value = await _api.programNames();
      programsList.assignAll(value?.programs ?? []);
    } catch (e) {
      log('Error loading programs: $e');
    } finally {
      isProgramLoading.value = false;
    }
  }

  Future<void> getAttendance(String id, {String? batch, int? programIdFilter}) async {
    isAttendanceLoading.value = true;
    return _api.getAttendance(admissionNumber: id, batch: batch, programId: programIdFilter).then((value) {
      attendanceList.assignAll(value?.attendance ?? []);
      attendanceList.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
      isLoading.value = false;
      isAttendanceLoading.value = false;

      totalHours.value = attendanceList.fold(0, (sum, element) => sum + (element.hours ?? 0));
      totalPrograms.value = attendanceList.length;
    });
  }

  bool onSubmitAttendanceValidation() {
    if (programId == null) {
      CustomWidgets.showSnackBar('Invalid', 'Please select a valid program');
      return false;
    }
    if (durationController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter duration/hours');
      return false;
    }
    if (selectedVolList.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please select volunteers');
      return false;
    }
    return true;
  }

  Future<void> onSubmitAttendance() async {
    if (!onSubmitAttendanceValidation()) return;
    isLoading.value = true;
    int hours = int.tryParse(durationController.text) ?? 0;

    List<Map<String, dynamic>> list = selectedVolList.map((v) => {
      'volunteer': v.admissionNo,
      'hours': hours,
    }).toList();

    _api.bulkAddAttendance(programId!, list).then((val) {
      isLoading.value = false;
      if (val?.status ?? false) {
        Get.back();
        Get.back();
        CustomWidgets.showSnackBar('Success', val?.message ?? 'Attendance added successfully');
      } else {
        CustomWidgets.showSnackBar('Error', val?.message ?? 'Failed to add attendance');
      }
    });
  }

  Future<void> updateAttendanceRecord(int attendanceId, int hours, String volunteerAdmn) async {
    isLoading.value = true;
    _api.updateAttendance(attendanceId, hours).then((val) {
      isLoading.value = false;
      if (val?.status ?? false) {
        Get.back();
        CustomWidgets.showSnackBar('Success', val?.message ?? 'Attendance updated successfully');
        getAttendance(volunteerAdmn);
      } else {
        CustomWidgets.showSnackBar('Error', val?.message ?? 'Failed to update attendance');
      }
    });
  }

  Future<void> deleteAttendance(int id, {String? volunteerAdmn}) async {
    isDeleteButtonLoading.value = true;
    _api.deleteAttendance(id).then((value) {
      isDeleteButtonLoading.value = false;
      if (value?.status ?? false) {
        Get.back();
        CustomWidgets.showSnackBar("Success", value?.message ?? "Attendance deleted successfully.");
        if (volunteerAdmn != null) getAttendance(volunteerAdmn);
      } else {
        CustomWidgets.showSnackBar("Error", value?.message ?? 'Failed to delete attendance.');
      }
    });
  }

  void onSearchTextChanged(String value) {
    if (value.isEmpty) {
      searchController.clear();
      searchList.assignAll(usersList);
    } else {
      final filtered = usersList.where((volunteer) {
        final name = volunteer.name?.toLowerCase() ?? '';
        final admnNo = volunteer.admissionNo ?? '';
        return admnNo.contains(value.toLowerCase()) || name.contains(value.toLowerCase());
      }).toList();

      searchList.assignAll(filtered);
    }
  }
}
