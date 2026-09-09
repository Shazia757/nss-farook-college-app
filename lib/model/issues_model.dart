import 'package:nss_new/model/volunteer_model.dart';

class Issues {
  String? to;
  DateTime? createdDate;
  int? id;
  DateTime? updatedDate;
  String? subject;
  String? description;
  Volunteer? createdBy;
  String? createdByName;
  String? updatedBy;
  bool? isOpen;

  Issues({
    this.to,
    this.createdDate,
    this.createdBy,
    this.createdByName,
    this.subject,
    this.description,
    this.updatedBy,
    this.id,
    this.updatedDate,
    this.isOpen,
  });

  factory Issues.fromJson(Map<String, dynamic> data) {
    Volunteer? vol;
    String? volName;
    if (data['created_by'] is Map<String, dynamic>) {
      vol = Volunteer.fromJson(data['created_by']);
      volName = vol.name;
    } else if (data['created_by'] != null) {
      volName = data['created_by'].toString();
    }

    return Issues(
      to: data['assigned_to']?.toString(),
      createdDate: data['created_at'] != null ? DateTime.tryParse(data['created_at'].toString()) : null,
      updatedDate: data['updated_at'] != null ? DateTime.tryParse(data['updated_at'].toString()) : null,
      subject: data['subject']?.toString(),
      description: data['description']?.toString(),
      createdBy: vol,
      createdByName: volName,
      id: data['id'] is int ? data['id'] as int : int.tryParse(data['id']?.toString() ?? ''),
      updatedBy: data['updated_by']?.toString(),
      isOpen: data['is_open'] is bool ? data['is_open'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assigned_to': to,
      'created_at': createdDate?.toIso8601String(),
      'updated_at': updatedDate?.toIso8601String(),
      'subject': subject,
      'description': description,
      'id': id,
      'updated_by': updatedBy,
      'created_by': createdBy?.toJson() ?? createdByName,
      'is_open': isOpen,
    };
  }
}

class IssueResponse {
  bool? status;
  String? message;
  List<Issues>? openIssues;
  List<Issues>? closedIssues;

  IssueResponse({
    this.status,
    this.message,
    this.openIssues,
    this.closedIssues,
  });

  factory IssueResponse.fromJson(dynamic json) {
    if (json is List) {
      final list = json.map((e) => Issues.fromJson(e as Map<String, dynamic>)).toList();
      return IssueResponse(
        status: true,
        openIssues: list.where((i) => i.isOpen == true).toList(),
        closedIssues: list.where((i) => i.isOpen == false).toList(),
      );
    } else if (json is Map<String, dynamic>) {
      return IssueResponse(
        status: json['status'] as bool? ?? true,
        message: json['message'] as String?,
        openIssues: (json['open_issues'] as List<dynamic>?)
            ?.map((e) => Issues.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        closedIssues: (json['closed_issues'] as List<dynamic>?)
            ?.map((e) => Issues.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );
    }
    return IssueResponse(status: false, openIssues: [], closedIssues: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'open_issues': openIssues?.map((e) => e.toJson()).toList(),
      'closed_issues': closedIssues?.map((e) => e.toJson()).toList(),
    };
  }
}
