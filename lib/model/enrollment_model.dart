import 'package:nss_new/model/volunteer_model.dart';

class ProgramEnrollmentDetails {
  DateTime? date;
  int? id;
  int? program;
  Volunteer? volunteer;
  String? volunteerAdmissionNo;

  ProgramEnrollmentDetails({
    this.id,
    this.date,
    this.volunteer,
    this.volunteerAdmissionNo,
    this.program,
  });

  factory ProgramEnrollmentDetails.fromJson(Map<String, dynamic> json) {
    Volunteer? vol;
    String? admnNo;
    if (json['volunteer'] is Map<String, dynamic>) {
      vol = Volunteer.fromJson(json['volunteer']);
      admnNo = vol.admissionNo;
    } else if (json['volunteer'] != null) {
      admnNo = json['volunteer'].toString();
    }

    return ProgramEnrollmentDetails(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      volunteer: vol,
      volunteerAdmissionNo: admnNo,
      date: json['enrollment_date'] != null ? DateTime.tryParse(json['enrollment_date'].toString()) : null,
      program: json['program'] is int ? json['program'] as int : int.tryParse(json['program']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enrollment_date': date?.toIso8601String(),
      'volunteer': volunteer?.toJson() ?? volunteerAdmissionNo,
      'program': program,
    };
  }
}

class EnrollmentResponse {
  bool? status;
  String? message;
  List<ProgramEnrollmentDetails>? enrollmentList;

  EnrollmentResponse({
    this.status,
    this.message,
    this.enrollmentList,
  });

  factory EnrollmentResponse.fromJson(dynamic json) {
    if (json is List) {
      return EnrollmentResponse(
        status: true,
        enrollmentList: json.map((e) => ProgramEnrollmentDetails.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final listData = json['enrollment_list'] ?? json['enrollments'] ?? json['data'] ?? json['results'];
      return EnrollmentResponse(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        enrollmentList: listData is List
            ? listData.map((e) => ProgramEnrollmentDetails.fromJson(e as Map<String, dynamic>)).toList()
            : [],
      );
    }
    return EnrollmentResponse(status: false, enrollmentList: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'enrollment_list': enrollmentList?.map((e) => e.toJson()).toList(),
    };
  }
}
