class Attendance {
  int? id;
  String? name;
  DateTime? date;
  String? markedBy;
  int? hours;
  String? admissionNo;
  int? programId;

  Attendance({
    this.id,
    this.name,
    this.admissionNo,
    this.date,
    this.hours,
    this.markedBy,
    this.programId,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    String? programName;
    int? pId;
    DateTime? attDate;

    if (json['program'] is Map<String, dynamic>) {
      final program = json['program'] as Map<String, dynamic>;
      programName = program['name']?.toString();
      pId = program['id'] is int ? program['id'] : int.tryParse(program['id']?.toString() ?? '');
      if (program['date'] != null) {
        attDate = DateTime.tryParse(program['date'].toString());
      }
    } else if (json['program'] is int) {
      pId = json['program'] as int;
    } else if (json['program'] != null) {
      pId = int.tryParse(json['program'].toString());
    }

    String? volunteerAdmn;
    if (json['volunteer'] is Map<String, dynamic>) {
      volunteerAdmn = json['volunteer']['admission_number']?.toString() ?? json['volunteer']['name']?.toString();
    } else if (json['volunteer'] != null) {
      volunteerAdmn = json['volunteer'].toString();
    }

    String? markedByName;
    if (json['marked_by'] is Map<String, dynamic>) {
      markedByName = json['marked_by']['name']?.toString();
    } else if (json['marked_by'] != null) {
      markedByName = json['marked_by'].toString();
    }

    if (json['created_at'] != null && attDate == null) {
      attDate = DateTime.tryParse(json['created_at'].toString());
    }

    return Attendance(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: programName ?? json['program_name']?.toString() ?? json['name']?.toString(),
      admissionNo: volunteerAdmn ?? json['admission_number']?.toString(),
      date: attDate,
      hours: json['hours'] is int ? json['hours'] as int : int.tryParse(json['hours']?.toString() ?? '0'),
      markedBy: markedByName,
      programId: pId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program': programId,
      'program_name': name,
      'date': date?.toIso8601String(),
      'hours': hours,
      'marked_by': markedBy,
      'volunteer': admissionNo,
    };
  }
}

class AttendanceResponse {
  bool? status;
  String? message;
  List<Attendance>? attendance;

  AttendanceResponse({this.status, this.message, this.attendance});

  factory AttendanceResponse.fromJson(dynamic json) {
    if (json is List) {
      return AttendanceResponse(
        status: true,
        attendance: json.map((e) => Attendance.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final attData = json['attendance_details'] ?? json['attendance'] ?? json['data'] ?? json['results'];
      return AttendanceResponse(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        attendance: attData is List
            ? attData.map((e) => Attendance.fromJson(e as Map<String, dynamic>)).toList()
            : [],
      );
    }
    return AttendanceResponse(status: false, attendance: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'attendance_details': attendance?.map((e) => e.toJson()).toList(),
    };
  }
}
