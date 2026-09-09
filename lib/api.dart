import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:nss_new/config/urls.dart';
import 'package:nss_new/config/utils.dart';
import 'package:nss_new/model/attendance_model.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/department_model.dart';
import 'package:nss_new/model/enrollment_model.dart';
import 'package:nss_new/model/issues_model.dart';
import 'package:nss_new/model/program_officer_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/model/volunteer_model.dart';

class Api {
  //------------------ 1. Auth & Password ---------------------------//

  Future<LoginResponse?> login(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.login),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error during login: $e');
    }
    return null;
  }

  Future<LoginResponse?> logout() async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.logout),
            body: jsonEncode({}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error during logout: $e');
    }
    return null;
  }

  Future<GeneralResponse?> changePassword(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.changePassword),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error during changePassword: $e');
    }
    return null;
  }

  Future<GeneralResponse?> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.resetPassword),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error during resetPassword: $e');
    }
    return null;
  }

  Future<GeneralResponse?> checkVersion() async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.checkVersion),
            body: jsonEncode({}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      return GeneralResponse.fromJson(responseJson);
    } catch (e) {
      checkConnectivity();
      log('Api error during checkVersion: $e');
      return GeneralResponse(status: true);
    }
  }

  //------------------ 2. Volunteers ---------------------------//

  Future<VolunteerList?> getVolunteers({
    String? batch,
    int? department,
    String? bloodGroup,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (batch != null && batch.isNotEmpty) queryParams['batch'] = batch;
      if (department != null) queryParams['department'] = department.toString();
      if (bloodGroup != null && bloodGroup.isNotEmpty)
        queryParams['blood_group'] = bloodGroup;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(
        Urls.getVolunteers,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return VolunteerList.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getVolunteers: $e');
    }
    return null;
  }

  Future<VolunteerList?> getPassiveVolunteers({
    String? batch,
    int? department,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (batch != null && batch.isNotEmpty) queryParams['batch'] = batch;
      if (department != null) queryParams['department'] = department.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(
        Urls.getPassiveVolunteers,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return VolunteerList.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getPassiveVolunteers: $e');
    }
    return null;
  }

  Future<VolunteerDetailResponse?> volunteerDetails(String admissionNo) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.volunteerDetails),
            body: jsonEncode({'admission_number': admissionNo}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return VolunteerDetailResponse.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error volunteerDetails: $e');
    }
    return null;
  }

  Future<GeneralResponse?> addVolunteer(Map<String, dynamic> user) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addVolunteer),
            body: jsonEncode(user),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error addVolunteer: $e');
    }
    return null;
  }

  Future<GeneralResponse?> updateVolunteer(Map<String, dynamic> data) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.updateVolunteer),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error updateVolunteer: $e');
    }
    return null;
  }

  Future<GeneralResponse?> deleteVolunteer(String? admissionNumber) async {
    try {
      final queryParams = <String, String>{};
      if (admissionNumber != null && admissionNumber.isNotEmpty) {
        queryParams['volunteer'] = admissionNumber;
      }

      final uri = Uri.parse(
        Urls.deleteVolunteer,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .delete(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error deleteVolunteer: $e');
    }
    return null;
  }

  Future<GeneralResponse?> setBatchStatus(String batch, bool isActive) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.setBatchStatus),
            body: jsonEncode({'batch': batch, 'is_active': isActive}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error setBatchStatus: $e');
    }
    return null;
  }

  Future<VolunteerHoursSummary?> getVolunteerHoursSummary({
    String? admissionNumber,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (admissionNumber != null && admissionNumber.isNotEmpty) {
        queryParams['admission_number'] = admissionNumber;
      }
      final uri = Uri.parse(
        Urls.getVolunteerHoursSummary,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return VolunteerHoursSummary.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getVolunteerHoursSummary: $e');
    }
    return null;
  }

  Future<List<BatchSummary>?> getBatches() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getBatches), headers: await getHeader())
          .timeout(const Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((e) => BatchSummary.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          final batches =
              decoded['batches'] ?? decoded['data'] ?? decoded['results'];
          if (batches is List) {
            return batches
                .map((e) => BatchSummary.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getBatches: $e');
    }
    return null;
  }

  Future<http.Response?> exportVolunteersExcel({
    String? batch,
    int? department,
    String? bloodGroup,
    bool? isActive,
    String? search,
    List<String>? fields,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (batch != null && batch.isNotEmpty) queryParams['batch'] = batch;
      if (department != null) queryParams['department'] = department.toString();
      if (bloodGroup != null && bloodGroup.isNotEmpty)
        queryParams['blood_group'] = bloodGroup;
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (fields != null && fields.isNotEmpty)
        queryParams['fields'] = fields.join(',');

      final uri = Uri.parse(
        Urls.exportVolunteersExcel,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 90));
      return response;
    } catch (e) {
      checkConnectivity();
      log('Api error exportVolunteersExcel: $e');
    }
    return null;
  }

  //------------------ 3. Program Officers ---------------------------//

  Future<List<ProgramOfficer>?> getProgramOfficers() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getProgramOfficers), headers: await getHeader())
          .timeout(const Duration(seconds: 60));
      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((e) => ProgramOfficer.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          final data =
              decoded['program_officers'] ??
              decoded['data'] ??
              decoded['results'];
          if (data is List) {
            return data
                .map((e) => ProgramOfficer.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getProgramOfficers: $e');
    }
    return null;
  }

  Future<ProgramOfficer?> addProgramOfficer(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addProgramOfficer),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ProgramOfficer.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error addProgramOfficer: $e');
    }
    return null;
  }

  Future<ProgramOfficer?> updateProgramOfficer(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.updateProgramOfficer),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ProgramOfficer.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error updateProgramOfficer: $e');
    }
    return null;
  }

  Future<GeneralResponse?> deleteProgramOfficer(String admissionNo) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteProgramOfficer),
            body: jsonEncode({'admission_number': admissionNo}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error deleteProgramOfficer: $e');
    }
    return null;
  }

  //------------------ 4. Programs & Enrollment ---------------------------//

  Future<ProgramResponse?> allPrograms({String? search, String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri.parse(
        Urls.getAllPrograms,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return ProgramResponse.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error allPrograms: $e');
    }
    return null;
  }

  Future<ProgramNameResponse?> programNames() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getProgramNames), headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return ProgramNameResponse.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error programNames: $e');
    }
    return null;
  }

  Future<ProgramResponse?> getUpcomingPrograms() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getUpcomingPrograms), headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return ProgramResponse.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getUpcomingPrograms: $e');
    }
    return null;
  }

  Future<GeneralResponse?> addProgram(Program program) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addProgram),
            body: jsonEncode(program.toJson()),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error addProgram: $e');
    }
    return null;
  }

  Future<GeneralResponse?> updateProgram(Map<String, dynamic> data) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.updateProgram),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error updateProgram: $e');
    }
    return null;
  }

  Future<GeneralResponse?> deleteProgram(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteProgram),
            body: jsonEncode({'id': id}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error deleteProgram: $e');
    }
    return null;
  }

  Future<GeneralResponse?> enrollToProgram(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.enrollToProgram),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error enrollToProgram: $e');
    }
    return null;
  }

  Future<GeneralResponse?> cancelEnrollment(
    int programId, {
    String? volunteer,
  }) async {
    try {
      final body = <String, dynamic>{'program': programId};
      if (volunteer != null && volunteer.isNotEmpty) {
        body['volunteer'] = volunteer;
      }
      final response = await http
          .post(
            Uri.parse(Urls.cancelEnrollment),
            body: jsonEncode(body),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error cancelEnrollment: $e');
    }
    return null;
  }

  Future<EnrollmentResponse?> getEnrolledStudents(int? id) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.getEnrolledStudents),
            body: jsonEncode({'id': id}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return EnrollmentResponse.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getEnrolledStudents: $e');
    }
    return null;
  }

  //------------------ 5. Attendance ---------------------------//

  Future<AttendanceResponse?> getAttendance({
    String? admissionNumber,
    String? batch,
    int? programId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (admissionNumber != null && admissionNumber.isNotEmpty)
        queryParams['admission_number'] = admissionNumber;
      if (batch != null && batch.isNotEmpty) queryParams['batch'] = batch;
      if (programId != null) queryParams['program_id'] = programId.toString();

      final uri = Uri.parse(
        Urls.getAttendance,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return AttendanceResponse.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getAttendance: $e');
    }
    return null;
  }

  Future<GeneralResponse?> addAttendance(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addAttendance),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error addAttendance: $e');
    }
    return null;
  }

  Future<GeneralResponse?> bulkAddAttendance(
    int programId,
    List<Map<String, dynamic>> attendances,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.bulkAddAttendance),
            body: jsonEncode({
              'program': programId,
              'attendances': attendances,
            }),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error bulkAddAttendance: $e');
    }
    return null;
  }

  Future<GeneralResponse?> updateAttendance(int attendanceId, int hours) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.updateAttendance),
            body: jsonEncode({'id': attendanceId, 'hours': hours}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error updateAttendance: $e');
    }
    return null;
  }

  Future<GeneralResponse?> deleteAttendance(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteAttendance),
            body: jsonEncode({'id': id}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error deleteAttendance: $e');
    }
    return null;
  }

  Future<http.Response?> exportAttendanceExcel({
    int? programId,
    String? batch,
    int? department,
    List<String>? fields,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (programId != null) queryParams['program_id'] = programId.toString();
      if (batch != null && batch.isNotEmpty) queryParams['batch'] = batch;
      if (department != null) queryParams['department'] = department.toString();
      if (fields != null && fields.isNotEmpty)
        queryParams['fields'] = fields.join(',');

      final uri = Uri.parse(
        Urls.exportAttendanceExcel,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 90));
      return response;
    } catch (e) {
      checkConnectivity();
      log('Api error exportAttendanceExcel: $e');
    }
    return null;
  }

  //------------------ 6. Blood Requests & Donations ---------------------------//

  Future<List<BloodDonationRequest>?> getBloodRequests({
    String? bloodGroup,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (bloodGroup != null && bloodGroup.isNotEmpty)
        queryParams['blood_group'] = bloodGroup;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri.parse(
        Urls.getBloodRequests,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map(
                (e) => BloodDonationRequest.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          final data =
              decoded['requests'] ?? decoded['data'] ?? decoded['results'];
          if (data is List) {
            return data
                .map(
                  (e) =>
                      BloodDonationRequest.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
        }
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getBloodRequests: $e');
    }
    return null;
  }

  Future<BloodDonationRequest?> addBloodRequest(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addBloodRequest),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;

        final requestData = decoded['data'];

        if (requestData is Map<String, dynamic>) {
          return BloodDonationRequest.fromJson(requestData);
        }
      }
    } catch (e) {
      checkConnectivity();
      log('Api error addBloodRequest: $e');
    }

    return null;
  }

  Future<BloodDonationRequest?> updateBloodRequest(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.updateBloodRequest),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;

        final requestData = decoded['data'];

        if (requestData is Map<String, dynamic>) {
          return BloodDonationRequest.fromJson(requestData);
        }
      }
    } catch (e) {
      checkConnectivity();
      log('Api error updateBloodRequest: $e');
    }

    return null;
  }

  Future<GeneralResponse?> deleteBloodRequest(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteBloodRequest),
            body: jsonEncode({'id': id}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error deleteBloodRequest: $e');
    }
    return null;
  }

  Future<List<EligibleDonor>?> searchDonors(
    String bloodGroup, {
    bool eligibleOnly = false,
  }) async {
    try {
      final queryParams = <String, String>{
        'blood_group': bloodGroup,
        'eligible_only': eligibleOnly.toString(),
      };
      final uri = Uri.parse(
        Urls.searchDonors,
      ).replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((e) => EligibleDonor.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          final data =
              decoded['donors'] ?? decoded['data'] ?? decoded['results'];
          if (data is List) {
            return data
                .map((e) => EligibleDonor.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      }
    } catch (e) {
      checkConnectivity();
      log('Api error searchDonors: $e');
    }
    return null;
  }

  Future<BloodDonationRecord?> addDonationRecord(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addDonationRecord),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return BloodDonationRecord.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error addDonationRecord: $e');
    }
    return null;
  }

  Future<List<BloodDonationRecord>?> getDonationHistory({
    String? bloodGroup,
    String? volunteer,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (bloodGroup != null && bloodGroup.isNotEmpty)
        queryParams['blood_group'] = bloodGroup;
      if (volunteer != null && volunteer.isNotEmpty)
        queryParams['volunteer'] = volunteer;

      final uri = Uri.parse(
        Urls.getDonationHistory,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map(
                (e) => BloodDonationRecord.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          final data =
              decoded['history'] ?? decoded['data'] ?? decoded['results'];
          if (data is List) {
            return data
                .map(
                  (e) =>
                      BloodDonationRecord.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
        }
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getDonationHistory: $e');
    }
    return null;
  }

  Future<GeneralResponse?> deleteDonationRecord(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteDonationRecord),
            body: jsonEncode({'id': id}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error deleteDonationRecord: $e');
    }
    return null;
  }

  //------------------ 7. Issues & Helpdesk ---------------------------//

  Future<IssueResponse?> getAdminIssues() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getAdminIssue), headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return IssueResponse.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getAdminIssues: $e');
    }
    return null;
  }

  Future<IssueResponse?> getVolIssues(String admissionNo) async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getVolIssue), headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return IssueResponse.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getVolIssues: $e');
    }
    return null;
  }

  Future<GeneralResponse?> addIssue(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(Urls.addIssue),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error addIssue: $e');
    }
    return null;
  }

  Future<GeneralResponse?> resolveIssue(Map<String, dynamic> data) async {
    try {
      final response = await http
          .patch(
            Uri.parse(Urls.resolveIssue),
            body: jsonEncode(data),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error resolveIssue: $e');
    }
    return null;
  }

  Future<GeneralResponse?> deleteIssue(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(Urls.deleteIssue),
            body: jsonEncode({'id': id}),
            headers: await getHeader(),
          )
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return GeneralResponse.fromJson(responseJson);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error deleteIssue: $e');
    }
    return null;
  }

  //------------------ 8. Metadata & Admins ---------------------------//

  Future<DepartmentList?> getDepartments() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getDepartments), headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return DepartmentList.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getDepartments: $e');
    }
    return null;
  }

  Future<VolunteerList?> getAdmins() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getAdmins), headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        final decoded = jsonDecode(response.body);
        return VolunteerList.fromJson(decoded);
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getAdmins: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getExportableFields() async {
    try {
      final response = await http
          .get(Uri.parse(Urls.getExportableFields), headers: await getHeader())
          .timeout(const Duration(seconds: 60));

      if (checkValidations(response.body)) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      checkConnectivity();
      log('Api error getExportableFields: $e');
    }
    return null;
  }
}
