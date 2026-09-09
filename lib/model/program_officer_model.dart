import 'package:nss_new/model/department_model.dart';

class ProgramOfficer {
  String? auth;
  String? admissionNo;
  String? name;
  String? email;
  String? phoneNumber;
  String? bloodGroup;
  DateTime? createdDate;
  DateTime? updatedDate;
  Department? department;
  int? departmentId;

  ProgramOfficer({
    this.auth,
    this.admissionNo,
    this.name,
    this.email,
    this.phoneNumber,
    this.bloodGroup,
    this.createdDate,
    this.updatedDate,
    this.department,
    this.departmentId,
  });

  factory ProgramOfficer.fromJson(Map<String, dynamic> json) {
    Department? dept;
    int? deptId;
    if (json['department'] is Map<String, dynamic>) {
      dept = Department.fromJson(json['department']);
      deptId = dept.id;
    } else if (json['department'] is int) {
      deptId = json['department'] as int;
    }

    return ProgramOfficer(
      auth: json['auth']?.toString(),
      admissionNo: json['admission_number']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      createdDate: json['created_date'] != null ? DateTime.tryParse(json['created_date']) : null,
      updatedDate: json['updated_date'] != null ? DateTime.tryParse(json['updated_date']) : null,
      department: dept,
      departmentId: deptId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admission_number': admissionNo,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'blood_group': bloodGroup,
      'department': departmentId ?? department?.id,
    };
  }
}
