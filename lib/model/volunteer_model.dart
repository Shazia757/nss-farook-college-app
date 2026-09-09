import 'package:nss_new/model/department_model.dart';
import 'package:nss_new/model/user_model.dart';

class VolunteerList {
  bool? status;
  String? message;
  List<Volunteer>? data;

  VolunteerList({this.status, this.message, this.data});

  factory VolunteerList.fromJson(dynamic json) {
    if (json is List) {
      return VolunteerList(
        status: true,
        data: json.map((e) => Volunteer.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final listData = json['data'] ?? json['volunteers'] ?? json['results'];
      return VolunteerList(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        data: listData is List
            ? listData.map((e) => Volunteer.fromJson(e as Map<String, dynamic>)).toList()
            : [],
      );
    }
    return VolunteerList(status: false, data: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class VolunteerDetailResponse {
  bool? status;
  String? message;
  Users? volunteerDetails;

  VolunteerDetailResponse({this.status, this.message, this.volunteerDetails});

  factory VolunteerDetailResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final details = json['volunteer_details'] ?? json['data'] ?? json;
      return VolunteerDetailResponse(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        volunteerDetails: details is Map<String, dynamic> ? Users.fromJson(details) : null,
      );
    }
    return VolunteerDetailResponse(status: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'volunteer_details': volunteerDetails?.toJson(),
    };
  }
}

class Volunteer {
  String? admissionNo;
  String? name;
  Department? department;
  int? departmentId;
  String? role;
  String? bloodGroup;
  String? address;
  String? phoneNumber;
  String? batch;
  bool isActive;

  Volunteer({
    this.admissionNo,
    this.name,
    this.department,
    this.departmentId,
    this.role,
    this.bloodGroup,
    this.address,
    this.phoneNumber,
    this.batch,
    this.isActive = true,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    Department? dept;
    int? deptId;
    if (json['department'] is Map<String, dynamic>) {
      dept = Department.fromJson(json['department']);
      deptId = dept.id;
    } else if (json['department'] is int) {
      deptId = json['department'] as int;
    }

    return Volunteer(
      admissionNo: json['admission_number']?.toString() ?? json['auth']?.toString(),
      name: json['name']?.toString(),
      department: dept,
      departmentId: deptId,
      role: json['role']?.toString() ?? 'vol',
      bloodGroup: json['blood_group']?.toString(),
      address: json['address']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      batch: json['batch']?.toString(),
      isActive: json['is_active'] is bool ? json['is_active'] : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admission_number': admissionNo,
      'name': name,
      'department': departmentId ?? department?.id,
      'role': role,
      'blood_group': bloodGroup,
      'address': address,
      'phone_number': phoneNumber,
      'batch': batch,
      'is_active': isActive,
    };
  }
}

class VolunteerHoursSummary {
  bool status;
  String message;
  String admissionNumber;
  int totalHours;
  int targetHours;
  double progressPercentage;
  List<ProgramHourBreakdown> programBreakdown;

  VolunteerHoursSummary({
    this.status = true,
    this.message = '',
    this.admissionNumber = '',
    this.totalHours = 0,
    this.targetHours = 240,
    this.progressPercentage = 0.0,
    this.programBreakdown = const [],
  });

  factory VolunteerHoursSummary.fromJson(Map<String, dynamic> json) {
    final breakdownJson = json['program_breakdown'] ?? json['programs'] ?? json['data'];
    List<ProgramHourBreakdown> breakdown = [];
    if (breakdownJson is List) {
      breakdown = breakdownJson.map((e) => ProgramHourBreakdown.fromJson(e as Map<String, dynamic>)).toList();
    }

    int total = json['total_hours'] is int ? json['total_hours'] : int.tryParse(json['total_hours']?.toString() ?? '0') ?? 0;
    int target = json['target_hours'] is int ? json['target_hours'] : 240;
    double progress = json['progress_percentage'] is num
        ? (json['progress_percentage'] as num).toDouble()
        : ((total / target) * 100).clamp(0.0, 100.0);

    return VolunteerHoursSummary(
      status: json['status'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      admissionNumber: json['admission_number']?.toString() ?? '',
      totalHours: total,
      targetHours: target,
      progressPercentage: progress,
      programBreakdown: breakdown,
    );
  }
}

class ProgramHourBreakdown {
  int? programId;
  String? programName;
  int hours;
  String? date;

  ProgramHourBreakdown({
    this.programId,
    this.programName,
    this.hours = 0,
    this.date,
  });

  factory ProgramHourBreakdown.fromJson(Map<String, dynamic> json) {
    return ProgramHourBreakdown(
      programId: json['program_id'] is int ? json['program_id'] : int.tryParse(json['program_id']?.toString() ?? ''),
      programName: json['program_name']?.toString() ?? json['name']?.toString(),
      hours: json['hours'] is int ? json['hours'] : int.tryParse(json['hours']?.toString() ?? '0') ?? 0,
      date: json['date']?.toString(),
    );
  }
}

class BatchSummary {
  String batch;
  int totalCount;
  int activeCount;
  int passiveCount;

  BatchSummary({
    required this.batch,
    this.totalCount = 0,
    this.activeCount = 0,
    this.passiveCount = 0,
  });

  factory BatchSummary.fromJson(Map<String, dynamic> json) {
    return BatchSummary(
      batch: json['batch']?.toString() ?? '',
      totalCount: json['total_volunteers'] ?? json['total_count'] ?? json['total'] ?? 0,
      activeCount: json['active_volunteers'] ?? json['active_count'] ?? json['active'] ?? 0,
      passiveCount: json['passive_volunteers'] ?? json['passive_count'] ?? json['passive'] ?? 0,
    );
  }
}
