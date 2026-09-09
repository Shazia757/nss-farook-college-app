class Department {
  String? name;
  String? category;
  int? id;

  Department({
    this.id,
    this.category,
    this.name,
  });

  factory Department.fromJson(Map<String, dynamic>? data) {
    if (data == null) return Department();
    final rawId = data['id'];
    int? parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString());
    }

    return Department(
      id: parsedId,
      category: data['category']?.toString(),
      name: data['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
    };
  }
}

class DepartmentList {
  bool? status;
  String? message;
  List<Department>? programs;

  DepartmentList({this.status, this.message, this.programs});

  factory DepartmentList.fromJson(dynamic json) {
    if (json is List) {
      return DepartmentList(
        status: true,
        programs: json.map((e) => Department.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final deptData = json['programs'] ?? json['departments'] ?? json['data'] ?? json['results'];
      return DepartmentList(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        programs: deptData is List
            ? deptData.map((e) => Department.fromJson(e as Map<String, dynamic>)).toList()
            : [],
      );
    }
    return DepartmentList(status: false, programs: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'programs': programs?.map((e) => e.toJson()).toList(),
    };
  }
}
