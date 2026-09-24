import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/model/department_model.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/view/volunteer/add_volunteer_screen.dart';
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
  void onReady() {
    super.onReady();
    getDepartments();
  }

  @override
  void onClose() {
    nameController.dispose();
    departmentController.dispose();
    courseController.dispose();
    emailController.dispose();
    phoneController.dispose();
    rollNoController.dispose();
    admissionNoController.dispose();
    dobController.dispose();
    yearController.dispose();
    casteController.dispose();
    genderController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void getDepartments() async {
    if (isClosed) return;
    api
        .getDepartments()
        .then((value) {
          if (isClosed) return;
          departmentList.assignAll(value?.programs?.toList() ?? []);
        })
        .catchError((_) {});
  }

  void addVolunteer() async {
    if (isClosed) return;
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
          if (isClosed) return;
          isUpdateButtonLoading.value = false;
          if (value?.status ?? false) {
            Get.back(); // close confirmation dialog
            Get.back(); // navigate back to Manage Volunteers
            CustomWidgets.showSnackBar(
              'Success',
              value?.message ?? 'Volunteer added successfully.',
              backgroundColor: Colors.green.shade800,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            );
          } else {
            Get.back(); // close confirmation dialog
            CustomWidgets.showSnackBar(
              'Error',
              value?.message ?? 'Failed to add volunteer.',
              backgroundColor: Colors.red.shade800,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        })
        .catchError((_) {
          if (!isClosed) {
            isUpdateButtonLoading.value = false;
            Get.back();
            CustomWidgets.showSnackBar(
              'Error',
              'Failed to add volunteer.',
              backgroundColor: Colors.red.shade800,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        });
  }

  void updateVolunteer() async {
    if (isClosed) return;
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
          if (isClosed) return;
          isUpdateButtonLoading.value = false;
          if (response?.status == true) {
            Get.back(); // close confirmation dialog
            Get.back(); // navigate back to previous screen
            CustomWidgets.showSnackBar(
              'Success',
              response?.message ?? 'Volunteer updated successfully.',
              backgroundColor: Colors.green.shade800,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            );
          } else {
            Get.back();
            CustomWidgets.showSnackBar(
              'Error',
              response?.message ?? 'Failed to update volunteer.',
              backgroundColor: Colors.red.shade800,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        })
        .catchError((_) {
          if (!isClosed) {
            isUpdateButtonLoading.value = false;
            Get.back();
            CustomWidgets.showSnackBar(
              'Error',
              'Failed to update volunteer.',
              backgroundColor: Colors.red.shade800,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        });
  }

  Future<bool> deleteVolunteer(String admnNo) async {
    if (isClosed) return false;
    isDeleteButtonLoading.value = true;
    try {
      final response = await api.deleteVolunteer(admnNo);
      if (isClosed) return false;
      Get.back(); // Dismiss confirmation dialog immediately
      if (response?.status ?? false) {
        CustomWidgets.showSnackBar(
          "Success",
          response?.message ?? "Volunteer deleted successfully.",
          backgroundColor: Colors.green.shade800,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
        return true;
      } else {
        CustomWidgets.showSnackBar(
          "Error",
          response?.message ?? "Failed to delete volunteer.",
          backgroundColor: Colors.red.shade800,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        return false;
      }
    } catch (e) {
      Get.back();
      CustomWidgets.showSnackBar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    } finally {
      if (!isClosed) {
        isDeleteButtonLoading.value = false;
      }
    }
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
    departmentID = null;
    selectedCaste.value = null;
    selectedGender.value = null;
    selectedBloodGroup.value = null;
    role.value = 'vol';
  }

  bool onSubmitVolValidation() {
    if (nameController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please enter name',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please enter email',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please enter phone number',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    if (admissionNoController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please add admission number',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
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

  int get activeFilterCount {
    int count = 0;
    if (selectedBloodGroup.value.isNotEmpty) count++;
    if (selectedBatch.value.isNotEmpty) count++;
    if (selectedDepartmentId.value != null) count++;
    return count;
  }

  void removeVolunteerLocally(String? admnNo) {
    if (admnNo == null || admnNo.isEmpty) return;
    usersList.removeWhere((v) => v.admissionNo == admnNo);
    passiveUsersList.removeWhere((v) => v.admissionNo == admnNo);
  }

  void updateVolunteerLocally(Volunteer updated) {
    if (updated.admissionNo == null || isClosed) return;
    final idx = usersList.indexWhere(
      (v) => v.admissionNo == updated.admissionNo,
    );
    if (idx != -1) {
      usersList[idx] = updated;
    }
    final pIdx = passiveUsersList.indexWhere(
      (v) => v.admissionNo == updated.admissionNo,
    );
    if (pIdx != -1) {
      passiveUsersList[pIdx] = updated;
    }
  }

  void addVolunteerLocally(Volunteer created) {
    if (isClosed) return;
    if (created.isActive != false) {
      usersList.insert(0, created);
    } else {
      passiveUsersList.insert(0, created);
    }
  }

  @override
  void onReady() {
    super.onReady();
    getData();
    fetchBatches();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void getData() {
    if (isClosed) return;
    isLoading.value = true;
    _api
        .getVolunteers(
          batch: selectedBatch.value,
          department: selectedDepartmentId.value,
          bloodGroup: selectedBloodGroup.value,
          search: searchQuery.value,
        )
        .then((value) {
          if (isClosed) return;
          final activeOnly = (value?.data ?? [])
              .where((v) => v.isActive != false)
              .toList();
          usersList.assignAll(activeOnly);
          isLoading.value = false;
        })
        .catchError((_) {
          if (!isClosed) isLoading.value = false;
        });
  }

  void getPassiveData() {
    if (isClosed) return;
    isPassiveLoading.value = true;
    _api
        .getPassiveVolunteers(
          batch: selectedBatch.value,
          department: selectedDepartmentId.value,
          search: searchQuery.value,
        )
        .then((value) {
          if (isClosed) return;
          passiveUsersList.assignAll(value?.data ?? []);
          isPassiveLoading.value = false;
        })
        .catchError((_) {
          if (!isClosed) isPassiveLoading.value = false;
        });
  }

  void fetchBatches() {
    if (isClosed) return;
    _api
        .getBatches()
        .then((list) {
          if (isClosed) return;
          if (list != null) {
            batchSummaries.assignAll(list);
          }
        })
        .catchError((_) {});
  }

  void togglePassiveView(bool showPassive) {
    if (isClosed) return;
    isShowingPassive.value = showPassive;
    if (showPassive) {
      getPassiveData();
    } else {
      getData();
    }
  }

  void setBatchStatus(String batch, bool isActive) {
    if (isClosed) return;
    isLoading.value = true;
    _api
        .setBatchStatus(batch, isActive)
        .then((res) {
          if (isClosed) return;
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
        })
        .catchError((_) {
          if (!isClosed) isLoading.value = false;
        });
  }

  void onSearchTextChanged(String value) {
    if (isClosed) return;
    searchQuery.value = value;
    if (isShowingPassive.value) {
      getPassiveData();
    } else {
      getData();
    }
  }

  void filterByBloodGroup(String group) {
    if (isClosed) return;
    selectedBloodGroup.value = selectedBloodGroup.value == group ? '' : group;
    getData();
  }

  void filterByBatch(String batch) {
    if (isClosed) return;
    selectedBatch.value = selectedBatch.value == batch ? '' : batch;
    if (isShowingPassive.value) {
      getPassiveData();
    } else {
      getData();
    }
  }

  void filterByDepartment(int? deptId) {
    if (isClosed) return;
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
    if (isClosed) return;
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
    if (admissionNo == null || admissionNo.isEmpty || isClosed) return;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    _api
        .volunteerDetails(admissionNo)
        .then((value) {
          Get.back();
          if (isClosed) return;
          if (value?.volunteerDetails != null) {
            Get.to(
              () => AddVolunteerScreen(volunteer: value!.volunteerDetails),
            )?.then((_) => getData());
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              'Failed to fetch volunteer details',
            );
          }
        })
        .catchError((_) {
          Get.back();
          CustomWidgets.showSnackBar(
            'Error',
            'Failed to fetch volunteer details',
          );
        });
  }

  void viewVolunteerProfile(String? admissionNo) {
    if (admissionNo == null || admissionNo.isEmpty || isClosed) return;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    _api
        .volunteerDetails(admissionNo)
        .then((value) {
          Get.back();
          if (isClosed) return;
          if (value?.volunteerDetails != null) {
            Get.to(
              () => ProfileScreen(volunteer: value!.volunteerDetails),
            )?.then((_) => getData());
          } else {
            CustomWidgets.showSnackBar(
              "Error",
              "Failed to load volunteer details",
            );
          }
        })
        .catchError((_) {
          Get.back();
        });
  }

  Future<void> fetchHoursSummary(String admissionNo) async {
    if (isClosed) return;
    final summary = await _api.getVolunteerHoursSummary(
      admissionNumber: admissionNo,
    );
    if (isClosed) return;
    if (summary != null) {
      volunteerHoursSummary.value = summary;
    }
  }
}
