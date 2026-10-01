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
      pId = program['id'] is int
          ? program['id']
          : int.tryParse(program['id']?.toString() ?? '');
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
      volunteerAdmn =
          json['volunteer']['admission_number']?.toString() ??
          json['volunteer']['name']?.toString();
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
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      name:
          programName ??
          json['program_name']?.toString() ??
          json['name']?.toString(),
      admissionNo: volunteerAdmn ?? json['admission_number']?.toString(),
      date: attDate,
      hours: json['hours'] is int
          ? json['hours'] as int
          : int.tryParse(json['hours']?.toString() ?? '0'),
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
        attendance: json
            .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final attData =
          json['attendance_details'] ??
          json['attendance'] ??
          json['data'] ??
          json['results'];
      return AttendanceResponse(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        attendance: attData is List
            ? attData
                  .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
                  .toList()
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

class ProgramAttendanceResponse {
  bool? status;
  String? message;
  int? programId;
  String? programName;
  int? count;
  List<String>? volunteers;
  List<ProgramAttendance>? data;

  ProgramAttendanceResponse({
    this.status,
    this.message,
    this.programId,
    this.programName,
    this.count,
    this.volunteers,
    this.data,
  });

  factory ProgramAttendanceResponse.fromJson(dynamic json) {
    if (json is List) {
      final list = json
          .whereType<Map<String, dynamic>>()
          .map((e) => ProgramAttendance.fromJson(e))
          .toList();
      return ProgramAttendanceResponse(
        status: true,
        count: list.length,
        data: list,
      );
    }

    if (json is! Map<String, dynamic>) {
      return ProgramAttendanceResponse(status: false, data: [], volunteers: []);
    }

    final rawData = json['data'] ??
        json['attendance'] ??
        json['attendances'] ??
        json['attendance_details'] ??
        json['results'];

    List<ProgramAttendance> dataList = [];
    if (rawData is List) {
      dataList = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => ProgramAttendance.fromJson(e))
          .toList();
    }

    final rawVolunteers = json['volunteers'] ?? json['volunteer_ids'];
    List<String> volList = [];
    if (rawVolunteers is List) {
      volList = rawVolunteers
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // If dataList is empty but volunteers list was returned, populate dataList from volunteers
    if (dataList.isEmpty && volList.isNotEmpty) {
      dataList = volList
          .map((v) => ProgramAttendance(volunteer: v))
          .toList();
    }

    final pId = json['program_id'] is int
        ? json['program_id'] as int
        : int.tryParse(
            json['program_id']?.toString() ??
                json['program']?.toString() ??
                json['id']?.toString() ??
                '',
          );

    final cnt = json['count'] is int
        ? json['count'] as int
        : int.tryParse(json['count']?.toString() ?? '');

    return ProgramAttendanceResponse(
      status: json['status'] as bool? ?? true,
      message: json['message']?.toString(),
      programId: pId,
      programName:
          json['program_name']?.toString() ?? json['name']?.toString(),
      count: cnt ?? (dataList.isNotEmpty ? dataList.length : volList.length),
      volunteers: volList,
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'program_id': programId,
      'program_name': programName,
      'count': count,
      'volunteers': volunteers,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class ProgramAttendance {
  String? volunteer;
  String? name;
  int? hours;

  ProgramAttendance({
    this.volunteer,
    this.name,
    this.hours,
  });

  factory ProgramAttendance.fromJson(Map<String, dynamic> json) {
    String? volunteerAdmn;
    String? volunteerName =
        json['name']?.toString() ?? json['volunteer_name']?.toString();

    if (json['volunteer'] is Map<String, dynamic>) {
      final volMap = json['volunteer'] as Map<String, dynamic>;
      volunteerAdmn = volMap['admission_number']?.toString() ??
          volMap['admission_no']?.toString() ??
          volMap['id']?.toString();
      volunteerName ??= volMap['name']?.toString();
    } else if (json['volunteer'] != null) {
      volunteerAdmn = json['volunteer'].toString();
    }

    volunteerAdmn ??= json['admission_number']?.toString() ??
        json['admission_no']?.toString() ??
        json['volunteer_admission_no']?.toString();

    int? hrs;
    if (json['hours'] is int) {
      hrs = json['hours'] as int;
    } else if (json['hours'] is num) {
      hrs = (json['hours'] as num).toInt();
    } else if (json['hours'] != null) {
      hrs = int.tryParse(json['hours'].toString());
    }

    return ProgramAttendance(
      volunteer: volunteerAdmn,
      name: volunteerName,
      hours: hrs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'volunteer': volunteer,
      'name': name,
      'hours': hours,
    };
  }
}