import 'package:nss_new/model/department_model.dart';

class Users {
  String? admissionNo;
  String? name;
  String? email;
  String? phoneNo;
  DateTime? dob;
  DateTime? createdDate;
  DateTime? updatedDate;
  Department? department;
  String? role;
  String? caste;
  String? gender;
  String? bloodGroup;
  String? createdBy;
  String? updatedBy;
  String? year;

  Users({
    this.admissionNo,
    this.name,
    this.email,
    this.phoneNo,
    this.dob,
    this.createdDate,
    this.updatedDate,
    this.department,
    this.role,
    this.bloodGroup,
    this.createdBy,
    this.updatedBy,
    this.year,
    this.caste,
    this.gender,
  });

  factory Users.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Users();
    Department? dept;
    if (json['department'] is Map<String, dynamic>) {
      dept = Department.fromJson(json['department'] as Map<String, dynamic>);
    } else if (json['department'] is int) {
      dept = Department(id: json['department'] as int);
    }

    final rawDob = json['date_of_birth'] ?? json['dob'];
    final rawCreated = json['created_date'] ?? json['created_at'];
    final rawUpdated = json['updated_date'] ?? json['updated_at'];

    return Users(
      admissionNo: (json['admission_number'] ??
              json['admission_no'] ??
              json['auth'])
          ?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phoneNo: (json['phone_number'] ??
              json['phone_no'] ??
              json['phoneNumber'])
          ?.toString(),
      dob: rawDob != null ? DateTime.tryParse(rawDob.toString()) : null,
      createdDate:
          rawCreated != null ? DateTime.tryParse(rawCreated.toString()) : null,
      updatedDate:
          rawUpdated != null ? DateTime.tryParse(rawUpdated.toString()) : null,
      department: dept,
      role: json['role']?.toString(),
      bloodGroup:
          (json['blood_group'] ?? json['bloodGroup'])?.toString(),
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      year: (json['batch'] ?? json['year'])?.toString(),
      caste: json['caste']?.toString(),
      gender: (json['gender'] ?? json['sex'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admission_number': admissionNo,
      'blood_group': bloodGroup,
      'role': role,
      'phone_number': phoneNo,
      'name': name,
      'email': email,
      'department': department?.toJson(),
      'date_of_birth': dob?.toString(),
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_date': createdDate?.toString(),
      'updated_date': updatedDate?.toString(),
      'batch': year,
      'caste': caste,
      'gender': gender,
    };
  }

  @override
  String toString() {
    return 'Login(username:$admissionNo,name:$name,role:$role,$caste,$createdBy)';
  }
}

class LoginResponse {
  bool? status;
  String? message;
  String? role;
  String? token;
  Users? data;

  LoginResponse({
    required this.status,
    required this.data,
    required this.role,
    this.message,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      data: json['data'] != null
          ? Users.fromJson(json['data'] as Map<String, dynamic>)
          : Users(),
      status: json['status'] as bool?,
      message: json['message'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'role': role, 'token': token};
  }

  @override
  String toString() {
    return 'status:$status,message:$message';
  }
}

class GeneralResponse {
  bool? status;
  String? message;
  dynamic data;

  GeneralResponse({required this.status, this.message, this.data});

  factory GeneralResponse.fromJson(Map<String, dynamic> json) {
    return GeneralResponse(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] ?? json['volunteer_details'] ?? json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data};
  }

  @override
  String toString() {
    return 'Add_volunteer(status:$status,message:$message)';
  }
}
