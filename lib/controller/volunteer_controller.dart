import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/model/department_model.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/view/add_volunteer_screen.dart';
import 'package:nss_new/view/profile_screen.dart';

class VolunteerController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController rollNoController = TextEditingController();
  TextEditingController admissionNoController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController casteController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  var isUpdateButtonLoading = false.obs;
  var isDeleteButtonLoading = false.obs;
  DateTime? dob;
  final api = Api();
  RxString role = 'vol'.obs;
  RxString caste = ''.obs;
  RxString gender = ''.obs;
  RxString bloodGroup = ''.obs;
  RxList<Department> departmentList = <Department>[].obs;
  RxnString selectedCaste = RxnString();
  RxnString selectedGender = RxnString();
  RxnString selectedBloodGroup = RxnString();

  int? departmentID;

  @override
  void onInit() {
    getDepartments();
    super.onInit();
  }

  void getDepartments() async {
    api.getDepartments().then((value) {
      departmentList.assignAll(value?.programs?.toList() ?? []);
    });
  }

  void addVolunteer() async {
    isUpdateButtonLoading.value = true;
    api
        .addVolunteer({
          'admission_number': admissionNoController.text,
          'name': nameController.text,
          'email': emailController.text,
          'phone_number': phoneController.text,
          'date_of_birth': dob != null
              ? DateFormat('yyyy-MM-dd').format(dob!)
              : dobController.text,
          'department': departmentID,
          'batch': yearController.text,
          'caste': casteController.text,
          'gender': selectedGender.value ?? genderController.text,
          'blood_group': selectedBloodGroup.value ?? bloodGroup.value,
          'address': addressController.text,
          'role': role.value,
        })
        .then((value) {
          isUpdateButtonLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            CustomWidgets.showSnackBar(
              'Success',
              value?.message ?? 'Volunteer added successfully.',
            );
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              value?.message ?? 'Failed to add volunteer.',
            );
          }
        });
  }

  void updateVolunteer() async {
    isUpdateButtonLoading.value = true;
    api
        .updateVolunteer({
          'admission_number': admissionNoController.text,
          'name': nameController.text,
          'email': emailController.text,
          'phone_number': phoneController.text,
          'date_of_birth': dob != null
              ? DateFormat('yyyy-MM-dd').format(dob!)
              : dobController.text,
          'department': departmentID,
          'batch': yearController.text,
          'caste': casteController.text,
          'gender': selectedGender.value ?? genderController.text,
          'blood_group': selectedBloodGroup.value ?? bloodGroup.value,
          'address': addressController.text,
          'role': role.value,
        })
        .then((response) {
          isUpdateButtonLoading.value = false;
          if (response?.status == true) {
            Get.back();
            CustomWidgets.showSnackBar(
              'Success',
              response?.message ?? 'Volunteer updated successfully.',
            );
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              response?.message ?? 'Failed to update volunteer.',
            );
          }
        });
  }

  Future<void> deleteVolunteer(String admnNo) async {
    isDeleteButtonLoading.value = true;
    api.deleteVolunteer(admnNo).then((response) {
      isDeleteButtonLoading.value = false;
      if (response?.status ?? false) {
        Get.back();
        Get.back();
        CustomWidgets.showSnackBar(
          "Success",
          response?.message ?? "Volunteer deleted successfully.",
        );
      } else {
        CustomWidgets.showSnackBar(
          "Error",
          response?.message ?? "Failed to delete volunteer.",
        );
      }
    });
  }

  void setUpdateData(Users user) {
    nameController.text = user.name ?? "";
    emailController.text = user.email ?? "";
    phoneController.text = user.phoneNo ?? "";
    departmentID = user.department?.id;
    departmentController.text =
        "${user.department?.category ?? ''} ${user.department?.name ?? ''}";

    admissionNoController.text = user.admissionNo ?? "";
    dobController.text = (user.dob != null)
        ? DateFormat('yyyy-MM-dd').format(user.dob!)
        : "";
    dob = user.dob;
    role.value = user.role ?? 'vol';
    yearController.text = user.year ?? "";
    casteController.text = user.caste ?? "";
    genderController.text = user.gender ?? "";
    selectedCaste.value = user.caste;
    selectedGender.value = user.gender;
    selectedBloodGroup.value = user.bloodGroup;
  }

  void clearTextFields() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    departmentController.clear();
    rollNoController.clear();
    admissionNoController.clear();
    dobController.clear();
    yearController.clear();
    casteController.clear();
    genderController.clear();
    addressController.clear();
    selectedCaste.value = null;
    selectedGender.value = null;
    selectedBloodGroup.value = null;
    role.value = 'vol';
  }

  bool onSubmitVolValidation() {
    if (nameController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter name');
      return false;
    }
    if (emailController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter email');
      return false;
    }
    if (phoneController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter phone number');
      return false;
    }
    if (admissionNoController.text.isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please add admission number');
      return false;
    }
    return true;
  }
}

class VolunteerListController extends GetxController {
  TextEditingController searchController = TextEditingController();
  final Api _api = Api();

  RxBool isLoading = true.obs;
  RxBool isPassiveLoading = false.obs;
  RxBool isShowingPassive = false.obs;

  RxList<Volunteer> usersList = <Volunteer>[].obs;
  RxList<Volunteer> passiveUsersList = <Volunteer>[].obs;
  RxList<BatchSummary> batchSummaries = <BatchSummary>[].obs;
  Rxn<VolunteerHoursSummary> volunteerHoursSummary =
      Rxn<VolunteerHoursSummary>();

  RxString selectedBatch = ''.obs;
  RxnInt selectedDepartmentId = RxnInt();
  RxString selectedBloodGroup = ''.obs;
  RxString searchQuery = ''.obs;

  List<String> get bloodGroups => [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void onInit() {
    getData();
    fetchBatches();
    super.onInit();
  }

  void getData() {
    isLoading.value = true;
    _api
        .getVolunteers(
          batch: selectedBatch.value,
          department: selectedDepartmentId.value,
          bloodGroup: selectedBloodGroup.value,
          search: searchQuery.value,
        )
        .then((value) {
          usersList.assignAll(value?.data ?? []);
          isLoading.value = false;
        });
  }

  void getPassiveData() {
    isPassiveLoading.value = true;
    _api
        .getPassiveVolunteers(
          batch: selectedBatch.value,
          department: selectedDepartmentId.value,
          search: searchQuery.value,
        )
        .then((value) {
          passiveUsersList.assignAll(value?.data ?? []);
          isPassiveLoading.value = false;
        });
  }

  void fetchBatches() {
    _api.getBatches().then((list) {
      if (list != null) {
        batchSummaries.assignAll(list);
      }
    });
  }

  void togglePassiveView(bool showPassive) {
    isShowingPassive.value = showPassive;
    if (showPassive) {
      getPassiveData();
    } else {
      getData();
    }
  }

  void setBatchStatus(String batch, bool isActive) {
    isLoading.value = true;
    _api.setBatchStatus(batch, isActive).then((res) {
      isLoading.value = false;
      if (res?.status ?? false) {
        CustomWidgets.showSnackBar(
          'Success',
          res?.message ?? 'Batch status updated',
        );
        getData();
        getPassiveData();
        fetchBatches();
      } else {
        CustomWidgets.showSnackBar(
          'Error',
          res?.message ?? 'Failed to update batch status',
        );
      }
    });
  }

  void onSearchTextChanged(String value) {
    searchQuery.value = value;
    if (isShowingPassive.value) {
      getPassiveData();
    } else {
      getData();
    }
  }

  void filterByBloodGroup(String group) {
    selectedBloodGroup.value = selectedBloodGroup.value == group ? '' : group;
    getData();
  }

  void filterByBatch(String batch) {
    selectedBatch.value = selectedBatch.value == batch ? '' : batch;
    if (isShowingPassive.value) {
      getPassiveData();
    } else {
      getData();
    }
  }

  void filterByDepartment(int? deptId) {
    selectedDepartmentId.value = selectedDepartmentId.value == deptId
        ? null
        : deptId;
    if (isShowingPassive.value) {
      getPassiveData();
    } else {
      getData();
    }
  }

  void clearFilters() {
    selectedBatch.value = '';
    selectedDepartmentId.value = null;
    selectedBloodGroup.value = '';
    searchQuery.value = '';
    searchController.clear();
    if (isShowingPassive.value) {
      getPassiveData();
    } else {
      getData();
    }
  }

  void updateVolunteer(String? admissionNo) {
    if (admissionNo == null || admissionNo.isEmpty) return;
    _api.volunteerDetails(admissionNo).then((value) {
      if (value?.volunteerDetails != null) {
        Get.to(
          () => AddVolunteerScreen(volunteer: value!.volunteerDetails),
        )?.then((_) => getData());
      }
    });
  }

  void viewVolunteerProfile(String? admissionNo) {
    if (admissionNo == null || admissionNo.isEmpty) return;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    _api.volunteerDetails(admissionNo).then((value) {
      Get.back();
      if (value?.volunteerDetails != null) {
        Get.to(
          () => ProfileScreen(volunteer: value!.volunteerDetails),
        )?.then((_) => getData());
      } else {
        CustomWidgets.showSnackBar("Error", "Failed to load volunteer details");
      }
    });
  }

  Future<void> fetchHoursSummary(String admissionNo) async {
    final summary = await _api.getVolunteerHoursSummary(
      admissionNumber: admissionNo,
    );
    if (summary != null) {
      volunteerHoursSummary.value = summary;
    }
  }
}
