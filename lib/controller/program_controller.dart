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

  TextEditingController searchController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  RxString date = 'newest'.obs;
  RxString selectedStatusFilter = ''.obs; // 'upcoming', 'past', or ''

  RxList<ProgramEnrollmentDetails> enrollmentList = <ProgramEnrollmentDetails>[].obs;
  RxList<Volunteer> selectedVolList = <Volunteer>[].obs;

  DateTime programDate = DateTime.now();
  RxString showProgramDate = ''.obs;

  @override
  void onInit() {
    getPrograms();
    super.onInit();
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
    isLoading.value = true;
    if (status != null) selectedStatusFilter.value = status;

    _api.allPrograms(search: searchController.text, status: selectedStatusFilter.value).then((value) {
      programsList.assignAll(value?.programs ?? []);
      _applySearchAndSort();
      isLoading.value = false;
    });
  }

  void getUpcomingPrograms() async {
    isLoading.value = true;
    selectedStatusFilter.value = 'upcoming';
    _api.getUpcomingPrograms().then((value) {
      programsList.assignAll(value?.programs ?? []);
      _applySearchAndSort();
      isLoading.value = false;
    });
  }

  void enrollInProgram(int programId, {String? volunteerAdmissionNo}) async {
    isButtonLoading.value = true;
    final map = <String, dynamic>{'program': programId};
    if (volunteerAdmissionNo != null && volunteerAdmissionNo.isNotEmpty) {
      map['volunteer'] = volunteerAdmissionNo;
    }
    _api.enrollToProgram(map).then((res) {
      isButtonLoading.value = false;
      if (res?.status ?? false) {
        CustomWidgets.showSnackBar('Success', res?.message ?? 'Enrolled successfully');
        getPrograms();
      } else {
        CustomWidgets.showSnackBar('Error', res?.message ?? 'Failed to enroll');
      }
    });
  }

  void cancelEnrollment(int programId, {String? volunteerAdmissionNo}) async {
    isButtonLoading.value = true;
    _api.cancelEnrollment(programId, volunteer: volunteerAdmissionNo).then((res) {
      isButtonLoading.value = false;
      if (res?.status ?? false) {
        CustomWidgets.showSnackBar('Success', res?.message ?? 'Enrollment cancelled');
        getPrograms();
      } else {
        CustomWidgets.showSnackBar('Error', res?.message ?? 'Failed to cancel enrollment');
      }
    });
  }

  void addAttendance(Program? program) async {
    if (program?.id == null) return;
    isLoading.value = true;
    int hours = int.tryParse(durationController.text) ?? program?.duration ?? 0;

    List<Map<String, dynamic>> attendances = selectedVolList.map((v) => {
      'volunteer': v.admissionNo,
      'hours': hours,
    }).toList();

    _api.bulkAddAttendance(program!.id!, attendances).then((val) {
      isLoading.value = false;
      if (val?.status ?? false) {
        Get.back();
        Get.back();
        CustomWidgets.showSnackBar('Success', 'Attendance recorded successfully');
      } else {
        CustomWidgets.showSnackBar('Error', val?.message ?? 'Failed to record attendance');
      }
    });
  }

  void getEnrolledStudents(Program? program, RxBool loading) async {
    if (program?.id == null) return;
    loading.value = true;
    _api.getEnrolledStudents(program?.id).then((value) {
      enrollmentList.assignAll(value?.enrollmentList?.toList() ?? []);
      selectAllVolunteers();
      durationController.text = "${program?.duration ?? 0}";
      programDate = program?.date ?? DateTime.now();
      showProgramDate.value = DateFormat.yMMMd().format(programDate);

      loading.value = false;
      Get.to(() => StudentsEnrollmentScreen(data: program));
    });
  }

  void onSearchTextChanged(String searchText) {
    _applySearchAndSort();
  }

  void _applySearchAndSort() {
    final query = searchController.text.toLowerCase();
    List<Program> filtered = [];

    if (query.isEmpty) {
      filtered = List.from(programsList);
    } else {
      filtered = programsList.where((p) => (p.name?.toLowerCase() ?? '').contains(query)).toList();
    }

    if (date.value == 'oldest') {
      filtered.sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
    } else {
      filtered.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    }

    searchList.assignAll(filtered);
  }

  void sortByDate() {
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

  void addProgram() {
    isUpdateButtonLoading.value = true;
    Api()
        .addProgram(
          Program(
            name: nameController.text,
            date: date,
            duration: int.tryParse(durationController.text) ?? 0,
            limit: int.tryParse(limitController.text) ?? 0,
            description: descController.text,
          ),
        )
        .then((value) {
          isUpdateButtonLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            Get.back();
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
        });
  }

  void updateProgram(int id) {
    isUpdateButtonLoading.value = true;
    Api()
        .updateProgram({
          'id': id,
          'name': nameController.text,
          'date': date?.toIso8601String() ?? dateController.text,
          'duration': durationController.text,
          'limit': int.tryParse(limitController.text) ?? 0,
          'description': descController.text,
        })
        .then((value) {
          isUpdateButtonLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            Get.back();
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
        });
  }

  Future<void> deleteProgram(int id) async {
    isDeleteButtonLoading.value = true;
    try {
      final value = await Api().deleteProgram(id);
      if (value?.status == true) {
        Get.back();
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
      isDeleteButtonLoading.value = false;
    }
  }

  bool onSubmitProgramValidation() {
    if (nameController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter program name');
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
    return true;
  }

  void setUpdateData(Program program) {
    nameController.text = program.name ?? '';
    descController.text = program.description ?? '';
    date = program.date;
    dateController.text = (program.date != null) ? DateFormat.yMMMd().format(program.date!) : '';
    durationController.text = (program.duration != null) ? program.duration.toString() : '';
    limitController.text = (program.limit != null) ? program.limit.toString() : '0';
  }

  void clearTextFields() {
    nameController.clear();
    durationController.clear();
    descController.clear();
    dateController.clear();
    limitController.clear();
  }
}
