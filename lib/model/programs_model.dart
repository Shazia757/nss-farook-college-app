class Program {
  int? id;
  String? name;
  String? description;
  DateTime? date;
  int? duration;
  int? limit;
  int? enrollmentCount;
  String? createdBy;

  Program({
    this.id,
    this.name,
    this.description,
    this.date,
    this.duration,
    this.limit,
    this.enrollmentCount,
    this.createdBy,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),

      enrollmentCount: json['enrollment_count'] is int
          ? json['enrollment_count'] as int
          : int.tryParse(json['enrollment_count']?.toString() ?? ''),

      name: json['name']?.toString(),

      description: json['description']?.toString(),

      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,

      limit: json['limit'] is int
          ? json['limit'] as int
          : int.tryParse(json['limit']?.toString() ?? ''),

      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? ''),

      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enrollment_count': enrollmentCount,
      'name': name,
      'description': description,
      'date': date?.toIso8601String(),
      'limit': limit,
      'duration': duration,
      'created_by': createdBy,
    };
  }
}

class ProgramResponse {
  bool? status;
  String? message;
  List<Program>? programs;

  ProgramResponse({this.status, this.message, this.programs});

  factory ProgramResponse.fromJson(dynamic json) {
    if (json is List) {
      return ProgramResponse(
        status: true,
        programs: json
            .map((e) => Program.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final progData = json['programs'] ?? json['data'] ?? json['results'];
      return ProgramResponse(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        programs: progData is List
            ? progData
                  .map((e) => Program.fromJson(e as Map<String, dynamic>))
                  .toList()
            : [],
      );
    }
    return ProgramResponse(status: false, programs: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'programs': programs?.map((e) => e.toJson()).toList(),
    };
  }
}

class ProgramNameResponse {
  bool? status;
  String? message;
  List<Program>? programs;

  ProgramNameResponse({this.status, this.message, this.programs});

  factory ProgramNameResponse.fromJson(dynamic json) {
    if (json is List) {
      return ProgramNameResponse(
        status: true,
        programs: json
            .map((e) => Program.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final progData = json['programs'] ?? json['data'] ?? json['results'];
      return ProgramNameResponse(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        programs: progData is List
            ? progData
                  .map((e) => Program.fromJson(e as Map<String, dynamic>))
                  .toList()
            : [],
      );
    }
    return ProgramNameResponse(status: false, programs: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'programs': programs?.map((e) => e.toJson()).toList(),
    };
  }
}
