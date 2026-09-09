import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/model/blood_model.dart';

class BloodRequirementController extends GetxController {
  final Api _api = Api();

  RxBool isLoading = false.obs;
  RxBool isDonorLoading = false.obs;
  RxBool isHistoryLoading = false.obs;

  RxList<BloodDonationRequest> requirements = <BloodDonationRequest>[].obs;
  RxList<EligibleDonor> eligibleDonors = <EligibleDonor>[].obs;
  RxList<BloodDonationRecord> donationHistory = <BloodDonationRecord>[].obs;

  RxString selectedBloodGroup = ''.obs;
  RxString selectedStatus = ''.obs;

  @override
  void onInit() {
    fetchBloodRequests();
    fetchDonationHistory();
    super.onInit();
  }

  Future<void> fetchBloodRequests({String? bloodGroup, String? status}) async {
    isLoading.value = true;
    try {
      final list = await _api.getBloodRequests(
        bloodGroup: bloodGroup ?? selectedBloodGroup.value,
        status: status ?? selectedStatus.value,
      );
      if (list != null) {
        requirements.assignAll(list);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addRequirement(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final res = await _api.addBloodRequest(data);
      if (res != null) {
        CustomWidgets.showSnackBar('Success', 'Blood request created successfully.');
        fetchBloodRequests();
        return true;
      } else {
        CustomWidgets.showSnackBar('Error', 'Failed to create blood request.');
      }
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> updateRequirement(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final res = await _api.updateBloodRequest(data);
      if (res != null) {
        CustomWidgets.showSnackBar('Success', 'Blood request updated successfully.');
        fetchBloodRequests();
        return true;
      } else {
        CustomWidgets.showSnackBar('Error', 'Failed to update blood request.');
      }
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<void> deleteRequirement(int id) async {
    isLoading.value = true;
    try {
      final res = await _api.deleteBloodRequest(id);
      if (res?.status ?? false) {
        CustomWidgets.showSnackBar('Success', res?.message ?? 'Request deleted successfully.');
        requirements.removeWhere((element) => element.id == id);
      } else {
        CustomWidgets.showSnackBar('Error', res?.message ?? 'Failed to delete request.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchEligibleDonors(String bloodGroup, {bool eligibleOnly = false}) async {
    isDonorLoading.value = true;
    try {
      final donors = await _api.searchDonors(bloodGroup, eligibleOnly: eligibleOnly);
      if (donors != null) {
        eligibleDonors.assignAll(donors);
      }
    } finally {
      isDonorLoading.value = false;
    }
  }

  Future<bool> recordDonation(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final res = await _api.addDonationRecord(data);
      if (res != null) {
        CustomWidgets.showSnackBar('Success', 'Donation record saved successfully.');
        fetchDonationHistory();
        fetchBloodRequests();
        return true;
      } else {
        CustomWidgets.showSnackBar('Error', 'Failed to record donation.');
      }
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<void> fetchDonationHistory({String? bloodGroup, String? volunteer}) async {
    isHistoryLoading.value = true;
    try {
      final history = await _api.getDonationHistory(bloodGroup: bloodGroup, volunteer: volunteer);
      if (history != null) {
        donationHistory.assignAll(history);
      }
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> deleteDonationHistoryRecord(int id) async {
    isLoading.value = true;
    try {
      final res = await _api.deleteDonationRecord(id);
      if (res?.status ?? false) {
        CustomWidgets.showSnackBar('Success', 'Donation record deleted.');
        donationHistory.removeWhere((e) => e.id == id);
      } else {
        CustomWidgets.showSnackBar('Error', res?.message ?? 'Failed to delete record.');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
