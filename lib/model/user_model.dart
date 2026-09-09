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
  String? rollNo;
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
    this.rollNo,
    this.createdBy,
    this.updatedBy,
    this.year,
    this.caste,
    this.gender,
  });

  factory Users.fromJson(Map<String, dynamic>? json) {
    return Users(
      admissionNo: json?['admission_number'] as String?,
      name: json?['name'] as String?,
      email: json?['email'] as String?,
      phoneNo: json?['phone_number'] as String?,
      dob: json?['date_of_birth'] != null
          ? DateTime.tryParse(json!['date_of_birth'].toString())
          : null,

      createdDate: json?['created_date'] != null
          ? DateTime.tryParse(json!['created_date'].toString())
          : null,

      updatedDate: json?['updated_date'] != null
          ? DateTime.tryParse(json!['updated_date'].toString())
          : null,
      department: json?['department'] != null
          ? Department.fromJson(json?['department'])
          : null,
      role: json?['role'] as String?,
      rollNo: json?['roll_number'] as String?,
      createdBy: json?['created_by'] as String?,
      updatedBy: json?['updated_by'] as String?,
      year: json?['batch'] as String?,
      caste: json?['caste'] as String?,
      gender: json?['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admission_number': admissionNo,
      'roll_number': rollNo,
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

  GeneralResponse({required this.status, this.message});

  factory GeneralResponse.fromJson(Map<String, dynamic> json) {
    return GeneralResponse(
      status: json['status'] as bool?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message};
  }

  @override
  String toString() {
    return 'Add_volunteer(status:$status,message:$message)';
  }
}
