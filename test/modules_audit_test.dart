import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/program_controller.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/volunteer_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('Add Program Date & Validation Tests', () {
    test('clearTextFields initializes date to null and clears controllers', () {
      final c = AddProgramController();
      c.nameController.text = "Tree Plantation";
      c.durationController.text = "3";
      c.date = DateTime(2026, 9, 15);
      c.dateController.text = "Sep 15, 2026";

      c.clearTextFields();

      expect(c.date, isNull);
      expect(c.dateController.text, isEmpty);
      expect(c.nameController.text, isEmpty);
      expect(c.durationController.text, isEmpty);
      c.onClose();
    });

    test(
      'onSubmitProgramValidation rejects empty date when adding program',
      () {
        final c = AddProgramController();
        c.nameController.text = "Blood Donation Camp";
        c.durationController.text = "4";
        c.date = null;
        c.dateController.text = "";

        expect(c.onSubmitProgramValidation(), isFalse);

        c.date = DateTime(2026, 10, 2);
        c.dateController.text = "Oct 2, 2026";
        expect(c.onSubmitProgramValidation(), isTrue);
        c.onClose();
      },
    );
  });

  group('Targeted Program CRUD Updates Tests', () {
    test('removeProgramLocally removes only the targeted item', () {
      final plc = ProgramListController();
      final p1 = Program(id: 101, name: 'Camp 1');
      final p2 = Program(id: 102, name: 'Camp 2');
      plc.programsList.assignAll([p1, p2]);
      plc.searchList.assignAll([p1, p2]);

      plc.removeProgramLocally(101);

      expect(plc.programsList.length, equals(1));
      expect(plc.programsList.first.id, equals(102));
      expect(plc.searchList.length, equals(1));
      expect(plc.searchList.first.id, equals(102));
      plc.onClose();
    });

    test(
      'updateProgramLocally replaces item in-place preserving unedited data',
      () {
        final plc = ProgramListController();
        final p1 = Program(id: 201, name: 'Original Name', enrollmentCount: 15);
        plc.programsList.assignAll([p1]);
        plc.searchList.assignAll([p1]);

        final updated = Program(id: 201, name: 'Updated Name');
        plc.updateProgramLocally(updated);

        expect(plc.programsList.first.name, equals('Updated Name'));
        expect(plc.programsList.first.enrollmentCount, equals(15));
        plc.onClose();
      },
    );
  });

  group('Manage Volunteer Filtering & Targeted Deletion Tests', () {
    test('VolunteerListController removes volunteer locally', () {
      final vlc = VolunteerListController();
      final v1 = Volunteer(admissionNo: 'ADM001', name: 'Zaid', isActive: true);
      final v2 = Volunteer(
        admissionNo: 'ADM002',
        name: 'Aisha',
        isActive: true,
      );
      vlc.usersList.assignAll([v1, v2]);

      vlc.removeVolunteerLocally('ADM001');

      expect(vlc.usersList.length, equals(1));
      expect(vlc.usersList.first.admissionNo, equals('ADM002'));
      vlc.onClose();
    });

    test('Volunteer model parses isActive correctly and defaults to true', () {
      final activeJson = {
        'admission_number': 'V001',
        'name': 'Active Vol',
        'is_active': true,
      };
      final passiveJson = {
        'admission_number': 'V002',
        'name': 'Passive Vol',
        'is_active': false,
      };

      final activeVol = Volunteer.fromJson(activeJson);
      final passiveVol = Volunteer.fromJson(passiveJson);

      expect(activeVol.isActive, isTrue);
      expect(passiveVol.isActive, isFalse);
    });
  });

  group('Blood Requirement Fallback and Model Tests', () {
    test('BloodDonationRequest parses created_by whether Map or String', () {
      final jsonWithMap = {
        'id': 50,
        'patient_name': 'Ramesh',
        'blood_group': 'B+',
        'units_required': 2,
        'hospital_name': 'Medical College',
        'created_by': {'name': 'Secretary John', 'role': 'sec'},
      };

      final req1 = BloodDonationRequest.fromJson(jsonWithMap);
      expect(req1.patientName, equals('Ramesh'));
      expect(req1.bloodGroup, equals('B+'));
      expect(req1.unitsRequired, equals(2));
      expect(req1.createdBy, equals('Secretary John'));

      final jsonWithString = {
        'id': 51,
        'patient_name': null,
        'blood_group': 'O-',
        'created_by': 'AdminDesk',
      };
      final req2 = BloodDonationRequest.fromJson(jsonWithString);
      expect(req2.patientName, equals(''));
      expect(req2.bloodGroup, equals('O-'));
      expect(req2.createdBy, equals('AdminDesk'));
    });

    test(
      'Phone sanitization preserves international codes and removes special characters',
      () {
        const raw1 = '+91 98765 43210';
        final sanitized1 = raw1.replaceAll(RegExp(r'[^0-9+]'), '');
        expect(sanitized1, equals('+919876543210'));

        const raw2 = '0495-2440234';
        final sanitized2 = raw2.replaceAll(RegExp(r'[^0-9+]'), '');
        expect(sanitized2, equals('04952440234'));
      },
    );
  });
}
