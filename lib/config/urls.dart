class Urls {
  static String base =
      // 'http://54.39.105.221:12800/api';
      // 'https://nss.noorabiyad.com/api';
      'https://nssapi.bvocfarookcollege.com/api';
  static String login = '$base/login/';
  static String changePassword = '$base/change_password/';
  static String resetPassword = '$base/reset_password/';
  static String getVolunteers = '$base/get_volunteers/';
  static String getAdmins = '$base/get_admins/';
  static String volunteerDetails = '$base/get_volunteer_details/';
  static String addVolunteer = '$base/add_volunteer/';
  static String updateVolunteer = '$base/update_volunteer/';
  static String deleteVolunteer = '$base/delete_volunteer/';
  static String getAllPrograms = '$base/get_all_programs/';
  static String getProgramNames = '$base/get_programs/';
  static String getUpcomingPrograms = '$base/get_upcoming_programs/';
  static String getEnrolledStudents = '$base/get_enrollment_list/';
  static String addProgram = '$base/add_program/';
  static String updateProgram = '$base/update_program/';
  static String deleteProgram = '$base/delete_program/';
  static String getDepartments = '$base/get_departments/';
  static String getAttendance = '$base/get_attendance/';
  static String addAttendance = '$base/add_attendance/';
  static String deleteAttendance = '$base/delete_attendance/';
  static String getAdminIssue = '$base/get_issue_by_role/';
  static String getVolIssue = '$base/get_issue_by_user/';
  static String addIssue = '$base/add_issue/';
  static String resolveIssue = '$base/resolve_issue/';
  static String enrollToProgram = '$base/enroll_program/';
  static String checkVersion = '$base/check_version/';
  static String logout = '$base/logout/';
}

class Details {
  static String appVersion = '0.0.1';
  static String contactNo1 = '+919745457585';
  static String contactNo2 = '+919497343998';
  static String contactEmail = 'nss@farookcollege.ac.in';
}
