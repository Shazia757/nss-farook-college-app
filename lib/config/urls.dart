class Urls {
  static String base = 'https://nssapi.bvocfarookcollege.com/api';

  // Auth & Password
  static String login = '$base/login/';
  static String logout = '$base/logout/';
  static String changePassword = '$base/change_password/';
  static String resetPassword = '$base/reset_password/';
  static String checkVersion = '$base/check_version/';

  // Volunteers
  static String getVolunteers = '$base/get_volunteers/';
  static String getPassiveVolunteers = '$base/get_passive_volunteers/';
  static String volunteerDetails = '$base/get_volunteer_details/';
  static String addVolunteer = '$base/add_volunteer/';
  static String updateVolunteer = '$base/update_volunteer/';
  static String deleteVolunteer = '$base/delete_volunteer/';
  static String setBatchStatus = '$base/set_batch_status/';
  static String getVolunteerHoursSummary = '$base/get_volunteer_hours_summary/';
  static String getBatches = '$base/get_batches/';
  static String exportVolunteersExcel = '$base/export_volunteers_excel/';

  // Program Officers
  static String getProgramOfficers = '$base/get_program_officers/';
  static String addProgramOfficer = '$base/add_program_officer/';
  static String updateProgramOfficer = '$base/update_program_officer/';
  static String deleteProgramOfficer = '$base/delete_program_officer/';

  // Programs & Enrollment
  static String getAllPrograms = '$base/get_all_programs/';
  static String getProgramNames = '$base/get_programs/';
  static String getUpcomingPrograms = '$base/get_upcoming_programs/';
  static String addProgram = '$base/add_program/';
  static String updateProgram = '$base/update_program/';
  static String deleteProgram = '$base/delete_program/';
  static String enrollToProgram = '$base/enroll_program/';
  static String cancelEnrollment = '$base/cancel_enrollment/';
  static String getEnrolledStudents = '$base/get_enrollment_list/';

  // Attendance
  static String getAttendance = '$base/get_attendance/';
  static String addAttendance = '$base/add_attendance/';
  static String bulkAddAttendance = '$base/bulk_add_attendance/';
  static String updateAttendance = '$base/update_attendance/';
  static String deleteAttendance = '$base/delete_attendance/';
  static String exportAttendanceExcel = '$base/export_attendance_excel/';

  // Blood Requirements & Donations
  static String getBloodRequests = '$base/get_blood_requests/';
  static String addBloodRequest = '$base/add_blood_request/';
  static String updateBloodRequest = '$base/update_blood_request/';
  static String deleteBloodRequest = '$base/delete_blood_request/';
  static String searchDonors = '$base/search_donors/';
  static String addDonationRecord = '$base/add_donation_record/';
  static String getDonationHistory = '$base/get_donation_history/';
  static String deleteDonationRecord = '$base/delete_donation_record/';

  // Issues
  static String getAdminIssue = '$base/get_issue_by_role/';
  static String getVolIssue = '$base/get_issue_by_user/';
  static String addIssue = '$base/add_issue/';
  static String resolveIssue = '$base/resolve_issue/';
  static String deleteIssue = '$base/delete_issue/';

  // Metadata & Admins
  static String getDepartments = '$base/get_departments/';
  static String getAdmins = '$base/get_admins/';
  static String getExportableFields = '$base/get_exportable_fields/';
}

class Details {
  static String appVersion = '1.0.0';
  static String contactNo1 = '+919745457585';
  static String contactNo2 = '+919497343998';
  static String contactEmail = 'nss@farookcollege.ac.in';
}

