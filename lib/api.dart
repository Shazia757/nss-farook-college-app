import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:nss_new/config/urls.dart';
import 'package:nss_new/config/utils.dart';
import 'package:nss_new/model/attendance_model.dart';
import 'package:nss_new/model/department_model.dart';
import 'package:nss_new/model/enrollment_model.dart';
import 'package:nss_new/model/issues_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/model/volunteer_model.dart';

class Api {
  //------------------Login---------------------------//

  Future<LoginResponse?> login(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.login),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error during login:$e');
    }
    return null;
  }

  //------------------Change Password---------------------------//

  Future<GeneralResponse?> changePassword(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.changePassword),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }
  //------------------Reset Password---------------------------//

  Future<GeneralResponse?> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.resetPassword),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------List Volunteer---------------------------//

  Future<VolunteerList?> getVolunteers() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getVolunteers), headers: await getHeader())
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return VolunteerList.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }
  //------------------List Admins---------------------------//

  Future<VolunteerList?> getAdmins() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getAdmins), headers: await getHeader())
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return VolunteerList.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Get Volunteer Details---------------------------//

  Future<VolunteerDetailResponse?> volunteerDetails(String admissionNo) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.volunteerDetails),
            body: jsonEncode({'admission_number': admissionNo}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return VolunteerDetailResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Add Volunteer---------------------------//

  Future<GeneralResponse?> addVolunteer(Map<String, dynamic> user) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addVolunteer),
            body: jsonEncode(user),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));
      log(user.toString());

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Update Volunteer---------------------------//

  Future<GeneralResponse?> updateVolunteer(Map<String, dynamic> data) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.updateVolunteer),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Delete Volunteer---------------------------//

  Future<GeneralResponse?> deleteVolunteer(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteVolunteer),
            body: jsonEncode({'volunteer': id}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Get All Programs---------------------------//

  Future<ProgramResponse?> allPrograms() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getAllPrograms), headers: await getHeader())
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return ProgramResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error fetching programs: $e');
    }
    return null;
  }

  //------------------Get Program Names---------------------------//

  Future<ProgramNameResponse?> programNames() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getProgramNames), headers: await getHeader())
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return ProgramNameResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error fetching programs: $e');
    }
    return null;
  }

  //------------------Upcoming Programs---------------------------//

  Future<ProgramResponse?> getUpcomingPrograms() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getUpcomingPrograms), headers: await getHeader())
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return ProgramResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error fetching upcoming programs: $e');
    }
    return null;
  }

  //------------------Add Program---------------------------//

  Future<GeneralResponse?> addProgram(Program program) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addProgram),
            body: jsonEncode(program.toJson()),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Update Program---------------------------//

  Future<GeneralResponse?> updateProgram(Map<String, dynamic> data) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.updateProgram),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Delete Program---------------------------//

  Future<GeneralResponse?> deleteProgram(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteProgram),
            body: jsonEncode({'id': id.toString()}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Get Departments---------------------------//

  Future<DepartmentList?> getDepartments() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getDepartments), headers: await getHeader())
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return DepartmentList.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }
  //------------------Get Students Enrolled---------------------------//

  Future<EnrollmentResponse?> getEnrolledStudents(int? id) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.getEnrolledStudents),
            body: jsonEncode({'id': id}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return EnrollmentResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }
  //------------------Get Attendance---------------------------//

  Future<AttendanceResponse?> getAttendance(String admissionNo) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              Urls.getAttendance,
            ).replace(queryParameters: {'admission_number': admissionNo}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return AttendanceResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Add Attendance---------------------------//

  Future<GeneralResponse?> addAttendance(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addAttendance),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Delete Attendance---------------------------//

  Future<GeneralResponse?> deleteAttendance(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteAttendance),
            body: jsonEncode({'id': id}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }
  //------------------version check---------------------------//

  Future<GeneralResponse?> checkVersion() async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.checkVersion),
            body: jsonEncode({}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      return GeneralResponse.fromJson(responseJson);
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
      return GeneralResponse(status: true);
    }
  }

  //------------------Get Admin Issues ---------------------------//

  Future<IssueResponse?> getAdminIssues() async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.getAdminIssue),
            body: jsonEncode({}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return IssueResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }
  //------------------Get Volunteer Issues ---------------------------//

  Future<IssueResponse?> getVolIssues(String admissionNo) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.getVolIssue),
            body: jsonEncode({'admission_number': admissionNo}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return IssueResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Add Issue---------------------------//

  Future<GeneralResponse?> addIssue(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addIssue),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }
  //------------------Resolve Issue---------------------------//

  Future<GeneralResponse?> resolveIssue(Map<String, dynamic> data) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.resolveIssue),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Enrollment---------------------------//

  Future<GeneralResponse?> enrollToProgram(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.enrollToProgram),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error:$e');
    }
    return null;
  }

  //------------------Logout---------------------------//

  Future<LoginResponse?> logout() async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.logout),
            body: jsonEncode({}),
            headers: await getHeader(),
          )
          .timeout(Duration(seconds: 60));

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      return LoginResponse.fromJson(responseJson);
    } catch (e) {
      checkConnectivity();
      log('Api error during logout:$e');
    }
    return null;
  }
}
