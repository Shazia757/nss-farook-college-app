import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/volunteer_model.dart';

class HomeController extends GetxController {
  final Api _api = Api();

  RxList<Program> upcomingPrograms = <Program>[].obs;
  RxList<BloodDonationRequest> openBloodRequests = <BloodDonationRequest>[].obs;
  Rxn<VolunteerHoursSummary> hoursSummary = Rxn<VolunteerHoursSummary>();

  RxBool isLoading = true.obs;
  RxBool isEnrolledLoading = false.obs;

  @override
  void onInit() {
    refreshDashboard();
    super.onInit();
  }

  void refreshDashboard() async {
    isLoading.value = true;
    await Future.wait([
      fetchUpcomingPrograms(),
      fetchOpenBloodRequests(),
      fetchVolunteerHours(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchUpcomingPrograms() async {
    final value = await _api.getUpcomingPrograms();
    if (value?.programs != null) {
      upcomingPrograms.assignAll(value!.programs!);
      upcomingPrograms.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    }
  }

  Future<void> fetchOpenBloodRequests() async {
    final requests = await _api.getBloodRequests(status: 'open');
    if (requests != null) {
      openBloodRequests.assignAll(requests);
    }
  }

  Future<void> fetchVolunteerHours() async {
    final user = LocalStorage().readUser();
    if (user.admissionNo != null && user.admissionNo!.isNotEmpty) {
      final summary = await _api.getVolunteerHoursSummary(admissionNumber: user.admissionNo);
      if (summary != null) {
        hoursSummary.value = summary;
      }
    }
  }

  void enroll(Program program) async {
    if (program.id == null) return;
    isEnrolledLoading.value = true;
    _api.enrollToProgram({'program': program.id}).then((response) {
      isEnrolledLoading.value = false;
      if (response?.status == true) {
        Get.back();
        CustomWidgets.showSnackBar('Success', response?.message ?? 'You are enrolled.');
        fetchUpcomingPrograms();
      } else {
        CustomWidgets.showSnackBar('Error', response?.message ?? 'Failed to enroll.');
      }
    });
  }
}
