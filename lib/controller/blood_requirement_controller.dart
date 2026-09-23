import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/model/blood_model.dart';

import 'package:nss_new/database/local_storage.dart';

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
  RxString selectedUrgency = ''.obs;
  RxString sortBy = 'newest'.obs;

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
    if (selectedStatus.value.isNotEmpty) count++;
    if (selectedUrgency.value.isNotEmpty) count++;
    if (sortBy.value != 'newest') count++;
    return count;
  }

  List<BloodDonationRequest> get filteredAndSortedRequirements {
    List<BloodDonationRequest> list = List.from(requirements);
    if (selectedBloodGroup.value.isNotEmpty) {
      list = list
          .where(
            (r) =>
                (r.bloodGroup ?? '').toUpperCase() ==
                selectedBloodGroup.value.toUpperCase(),
          )
          .toList();
    }
    if (selectedStatus.value.isNotEmpty) {
      list = list
          .where(
            (r) =>
                (r.status ?? '').toLowerCase() ==
                selectedStatus.value.toLowerCase(),
          )
          .toList();
    }
    if (selectedUrgency.value.isNotEmpty) {
      list = list
          .where(
            (r) =>
                (r.urgency ?? '').toLowerCase() ==
                selectedUrgency.value.toLowerCase(),
          )
          .toList();
    }

    if (sortBy.value == 'urgency') {
      int getWeight(String? u) {
        final s = (u ?? '').toLowerCase();
        if (s.contains('critical')) return 3;
        if (s.contains('urgent')) return 2;
        return 1;
      }

      list.sort((a, b) => getWeight(b.urgency).compareTo(getWeight(a.urgency)));
    } else if (sortBy.value == 'needed_date') {
      list.sort((a, b) {
        if (a.neededBefore == null && b.neededBefore == null) return 0;
        if (a.neededBefore == null) return 1;
        if (b.neededBefore == null) return -1;
        return a.neededBefore!.compareTo(b.neededBefore!);
      });
    } else if (sortBy.value == 'oldest') {
      list.sort(
        (a, b) => (a.createdAt ?? DateTime(2000)).compareTo(
          b.createdAt ?? DateTime(2000),
        ),
      );
    } else {
      // 'newest' default
      list.sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );
    }
    return list;
  }

  void applyFilters({
    String? bloodGroup,
    String? status,
    String? urgency,
    String? sort,
  }) {
    selectedBloodGroup.value = bloodGroup ?? '';
    selectedStatus.value = status ?? '';
    selectedUrgency.value = urgency ?? '';
    sortBy.value = sort ?? 'newest';
    fetchBloodRequests(bloodGroup: bloodGroup, status: status);
  }

  void resetFilters() {
    selectedBloodGroup.value = '';
    selectedStatus.value = '';
    selectedUrgency.value = '';
    sortBy.value = 'newest';
    fetchBloodRequests(bloodGroup: '', status: '');
  }

  @override
  void onReady() {
    super.onReady();
    fetchBloodRequests();
    final user = LocalStorage().readUser();
    if (user.role != 'vol') {
      fetchDonationHistory();
    }
  }

  Future<void> fetchBloodRequests({String? bloodGroup, String? status}) async {
    if (isClosed) return;
    isLoading.value = true;
    try {
      final list = await _api.getBloodRequests(
        bloodGroup: bloodGroup ?? selectedBloodGroup.value,
        status: status ?? selectedStatus.value,
      );
      if (isClosed) return;
      if (list != null) {
        requirements.assignAll(list);
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<bool> addRequirement(Map<String, dynamic> data) async {
    if (isClosed) return false;
    isLoading.value = true;
    try {
      final res = await _api.addBloodRequest(data);
      if (isClosed) return false;
      if (res != null) {
        CustomWidgets.showSnackBar(
          'Success',
          'Blood request created successfully.',
        );
        fetchBloodRequests();
        return true;
      } else {
        CustomWidgets.showSnackBar('Error', 'Failed to create blood request.');
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
    return false;
  }

  Future<bool> updateRequirement(Map<String, dynamic> data) async {
    if (isClosed) return false;
    isLoading.value = true;
    try {
      final res = await _api.updateBloodRequest(data);
      if (isClosed) return false;
      if (res != null) {
        CustomWidgets.showSnackBar(
          'Success',
          'Blood request updated successfully.',
        );
        fetchBloodRequests();
        return true;
      } else {
        CustomWidgets.showSnackBar('Error', 'Failed to update blood request.');
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
    return false;
  }

  Future<void> deleteRequirement(int id) async {
    if (isClosed) return;
    isLoading.value = true;
    try {
      final res = await _api.deleteBloodRequest(id);
      if (isClosed) return;
      if (res?.status ?? false) {
        CustomWidgets.showSnackBar(
          'Success',
          res?.message ?? 'Request deleted successfully.',
        );
        requirements.removeWhere((element) => element.id == id);
      } else {
        CustomWidgets.showSnackBar(
          'Error',
          res?.message ?? 'Failed to delete request.',
        );
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> searchEligibleDonors(
    String bloodGroup, {
    bool eligibleOnly = false,
  }) async {
    if (isClosed) return;
    isDonorLoading.value = true;
    try {
      final donors = await _api.searchDonors(
        bloodGroup,
        eligibleOnly: eligibleOnly,
      );
      if (isClosed) return;
      if (donors != null) {
        eligibleDonors.assignAll(donors);
      }
    } finally {
      if (!isClosed) {
        isDonorLoading.value = false;
      }
    }
  }

  Future<bool> recordDonation(Map<String, dynamic> data) async {
    if (isClosed) return false;
    isLoading.value = true;
    try {
      final res = await _api.addDonationRecord(data);
      if (isClosed) return false;
      if (res != null) {
        CustomWidgets.showSnackBar(
          'Success',
          'Donation record saved successfully.',
        );
        fetchDonationHistory();
        fetchBloodRequests();
        return true;
      } else {
        CustomWidgets.showSnackBar('Error', 'Failed to record donation.');
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
    return false;
  }

  Future<void> fetchDonationHistory({
    String? bloodGroup,
    String? volunteer,
  }) async {
    final user = LocalStorage().readUser();
    if (user.role == 'vol' || isClosed) return;
    isHistoryLoading.value = true;
    try {
      final history = await _api.getDonationHistory(
        bloodGroup: bloodGroup,
        volunteer: volunteer,
      );
      if (isClosed) return;
      if (history != null) {
        donationHistory.assignAll(history);
      }
    } finally {
      if (!isClosed) {
        isHistoryLoading.value = false;
      }
    }
  }

  Future<void> deleteDonationHistoryRecord(int id) async {
    if (isClosed) return;
    isLoading.value = true;
    try {
      final res = await _api.deleteDonationRecord(id);
      if (isClosed) return;
      if (res?.status ?? false) {
        CustomWidgets.showSnackBar('Success', 'Donation record deleted.');
        donationHistory.removeWhere((e) => e.id == id);
      } else {
        CustomWidgets.showSnackBar(
          'Error',
          res?.message ?? 'Failed to delete record.',
        );
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }
}
