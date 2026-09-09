class BloodDonationRequest {
  int? id;
  String? patientName;
  String? bloodGroup;
  int? unitsRequired;
  String? hospital;
  String? contactPerson;
  String? contactNumber;
  String? urgency;
  String? status;
  String? neededBefore;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdBy;

  BloodDonationRequest({
    this.id,
    this.patientName,
    this.bloodGroup,
    this.unitsRequired,
    this.hospital,
    this.contactPerson,
    this.contactNumber,
    this.urgency,
    this.status,
    this.neededBefore,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  factory BloodDonationRequest.fromJson(Map<String, dynamic> json) {
    return BloodDonationRequest(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      patientName: json['patient_name'] ?? json['patientName'] ?? '',
      bloodGroup: json['blood_group'] ?? json['bloodGroup'] ?? '',
      unitsRequired: json['units_required'] is int
          ? json['units_required']
          : int.tryParse(json['units_required']?.toString() ?? '1'),
      hospital: json['hospital'] ?? json['hospitalName'] ?? '',
      contactPerson: json['contact_person'] ?? json['contactPerson'] ?? '',
      contactNumber: json['contact_number'] ?? json['contactNumber'] ?? '',
      urgency: json['urgency'] ?? json['urgencyLevel'] ?? 'normal',
      status: json['status'] ?? 'open',
      neededBefore: json['needed_before'] ?? json['required_date'] ?? json['dateTime'],
      notes: json['notes'] ?? json['description'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'units_required': unitsRequired,
      'hospital': hospital,
      'contact_person': contactPerson,
      'contact_number': contactNumber,
      'urgency': urgency,
      'status': status,
      'required_date': neededBefore,
      'notes': notes,
    };
  }
}

class BloodDonationRecord {
  int? id;
  String? donationDate;
  String? bloodGroup;
  int? units;
  String? hospital;
  String? recipientName;
  String? notes;
  DateTime? createdAt;
  String? volunteer;
  int? request;
  String? verifiedBy;

  BloodDonationRecord({
    this.id,
    this.donationDate,
    this.bloodGroup,
    this.units,
    this.hospital,
    this.recipientName,
    this.notes,
    this.createdAt,
    this.volunteer,
    this.request,
    this.verifiedBy,
  });

  factory BloodDonationRecord.fromJson(Map<String, dynamic> json) {
    return BloodDonationRecord(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      donationDate: json['donation_date']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      units: json['units'] is int ? json['units'] : int.tryParse(json['units']?.toString() ?? '1'),
      hospital: json['hospital']?.toString(),
      recipientName: json['recipient_name']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      volunteer: json['volunteer']?.toString(),
      request: json['request'] is int ? json['request'] : int.tryParse(json['request']?.toString() ?? ''),
      verifiedBy: json['verified_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_date': donationDate,
      'blood_group': bloodGroup,
      'units': units,
      'hospital': hospital,
      'recipient_name': recipientName,
      'notes': notes,
      'volunteer': volunteer,
      'request': request,
    };
  }
}

class EligibleDonor {
  String? admissionNo;
  String? name;
  String? bloodGroup;
  String? phone;
  String? department;
  String? lastDonationDate;
  int? daysSinceLastDonation;
  bool isEligible;

  EligibleDonor({
    this.admissionNo,
    this.name,
    this.bloodGroup,
    this.phone,
    this.department,
    this.lastDonationDate,
    this.daysSinceLastDonation,
    this.isEligible = true,
  });

  factory EligibleDonor.fromJson(Map<String, dynamic> json) {
    return EligibleDonor(
      admissionNo: json['admission_number']?.toString() ?? json['volunteer']?.toString(),
      name: json['name']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      phone: json['phone_number']?.toString() ?? json['phone']?.toString(),
      department: json['department_name']?.toString() ?? json['department']?.toString(),
      lastDonationDate: json['last_donation_date']?.toString(),
      daysSinceLastDonation: json['days_since_last_donation'] is int
          ? json['days_since_last_donation']
          : int.tryParse(json['days_since_last_donation']?.toString() ?? '999'),
      isEligible: json['is_eligible'] ?? (json['cooldown_eligible'] ?? true),
    );
  }
}
