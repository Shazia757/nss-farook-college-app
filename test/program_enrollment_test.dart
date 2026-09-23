import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nss_new/controller/home_controller.dart';
import 'package:nss_new/controller/program_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => '.',
        );
    Get.testMode = true;
    await GetStorage.init();
    Get.reset();
    LocalStorage().clearAll();
  });

  group('Volunteer Enrollment Storage & Server Clock Tests', () {
    test('Saves and reads volunteer enrollments with volunteer isolation', () {
      final storage = LocalStorage();
      const vol1 = '2781';
      const vol2 = '2851';
      final now = DateTime.utc(2026, 9, 13, 12, 0, 0);

      storage.saveVolunteerEnrollment(vol1, 101, now);
      storage.saveVolunteerEnrollment(vol1, 102, now);

      final vol1Enrollments = storage.getVolunteerEnrollments(vol1);
      expect(vol1Enrollments.containsKey(101), isTrue);
      expect(vol1Enrollments.containsKey(102), isTrue);
      expect(vol1Enrollments[101], equals(now));

      // vol2 should have no enrollments (isolated)
      final vol2Enrollments = storage.getVolunteerEnrollments(vol2);
      expect(vol2Enrollments.isEmpty, isTrue);

      // Removing enrollment
      storage.removeVolunteerEnrollment(vol1, 101);
      final updatedVol1 = storage.getVolunteerEnrollments(vol1);
      expect(updatedVol1.containsKey(101), isFalse);
      expect(updatedVol1.containsKey(102), isTrue);
    });

    test('Server clock offset calculates estimated server time correctly', () {
      final storage = LocalStorage();
      const offset = Duration(minutes: 15);
      storage.saveServerClockOffset(offset);

      final estimated = storage.getEstimatedServerTime();
      final nowUtc = DateTime.now().toUtc();
      final difference = estimated.difference(nowUtc);

      // Should be roughly 15 minutes ahead
      expect(difference.inMinutes, inInclusiveRange(14, 16));
    });
  });

  group('ProgramListController Enrollment & 24h Cancellation Rule Tests', () {
    test('State 1: Volunteer not enrolled -> isEnrolled is false', () {
      LocalStorage().writeSession(
        user: Users(admissionNo: '2781', role: 'vol', name: 'Muhammed Jishad'),
        token: 'test_token',
      );

      final controller = ProgramListController();
      controller.loadVolunteerEnrollments();

      expect(controller.isEnrolled(999), isFalse);
      expect(controller.canCancelEnrollment(999), isFalse);
    });

    test(
      'State 2: Enrolled within 24 hours -> canCancelEnrollment is true',
      () {
        LocalStorage().writeSession(
          user: Users(
            admissionNo: '2781',
            role: 'vol',
            name: 'Muhammed Jishad',
          ),
          token: 'test_token',
        );

        final storage = LocalStorage();
        // Enrolled 2 hours ago
        final enrolledAt = storage.getEstimatedServerTime().subtract(
          const Duration(hours: 2),
        );
        storage.saveVolunteerEnrollment('2781', 105, enrolledAt);

        final controller = ProgramListController();
        controller.loadVolunteerEnrollments();

        expect(controller.isEnrolled(105), isTrue);
        expect(controller.canCancelEnrollment(105), isTrue);

        final remainingDuration = controller.getRemainingCancellationDuration(
          105,
        );
        expect(remainingDuration, isNotNull);
        expect(remainingDuration!.inHours, inInclusiveRange(21, 22));

        final text = controller.getRemainingCancellationText(105);
        expect(text, contains('left to cancel'));
      },
    );

    test(
      'State 3: Enrolled > 24 hours ago -> canCancelEnrollment is false (expired)',
      () {
        LocalStorage().writeSession(
          user: Users(
            admissionNo: '2781',
            role: 'vol',
            name: 'Muhammed Jishad',
          ),
          token: 'test_token',
        );

        final storage = LocalStorage();
        // Enrolled 25 hours ago (past the 24h limit)
        final enrolledAt = storage.getEstimatedServerTime().subtract(
          const Duration(hours: 25),
        );
        storage.saveVolunteerEnrollment('2781', 106, enrolledAt);

        final controller = ProgramListController();
        controller.loadVolunteerEnrollments();

        expect(controller.isEnrolled(106), isTrue);
        expect(controller.canCancelEnrollment(106), isFalse);

        final text = controller.getRemainingCancellationText(106);
        expect(text, equals('Cancellation window expired'));
      },
    );

    test('Loading protection sets prevent duplicate actions', () {
      final controller = ProgramListController();
      expect(controller.enrollingProgramIds.contains(50), isFalse);
      expect(controller.cancellingProgramIds.contains(50), isFalse);

      controller.enrollingProgramIds.add(50);
      expect(controller.enrollingProgramIds.contains(50), isTrue);

      controller.enrollingProgramIds.remove(50);
      expect(controller.enrollingProgramIds.contains(50), isFalse);
    });
  });

  group('HomeController Enrollment & Cancellation Tests', () {
    test(
      'HomeController correctly tracks volunteer enrollment and 24h rule',
      () {
        LocalStorage().writeSession(
          user: Users(admissionNo: '2851', role: 'vol', name: 'Zayan Ahmed'),
          token: 'test_token_2',
        );

        final storage = LocalStorage();
        final enrolledAt = storage.getEstimatedServerTime().subtract(
          const Duration(hours: 1),
        );
        storage.saveVolunteerEnrollment('2851', 201, enrolledAt);

        final homeController = HomeController();
        homeController.loadVolunteerEnrollments();

        expect(homeController.isEnrolled(201), isTrue);
        expect(homeController.canCancelEnrollment(201), isTrue);
        expect(homeController.isEnrolled(999), isFalse);

        final text = homeController.getRemainingCancellationText(201);
        expect(text, contains('left to cancel'));
      },
    );

    test(
      'Initial verification state: isCheckingEnrollment is true by default',
      () {
        final controller = ProgramListController();
        expect(controller.isCheckingEnrollment.value, isTrue);
        expect(controller.isEnrollmentVerified(21), isFalse);

        controller.verifiedProgramEnrollmentIds.add(21);
        controller.isCheckingEnrollment.value = false;

        expect(controller.isEnrollmentVerified(21), isTrue);
        expect(controller.isEnrollmentVerified(99), isFalse);
      },
    );

    test(
      'resetEnrollmentState clears all cached enrollment data on logout / account switch',
      () {
        final controller = ProgramListController();
        controller.enrolledPrograms[101] = DateTime.now();
        controller.verifiedProgramEnrollmentIds.add(101);
        controller.enrollingProgramIds.add(102);
        controller.isCheckingEnrollment.value = false;

        controller.resetEnrollmentState();

        expect(controller.enrolledPrograms.isEmpty, isTrue);
        expect(controller.verifiedProgramEnrollmentIds.isEmpty, isTrue);
        expect(controller.enrollingProgramIds.isEmpty, isTrue);
        expect(controller.isCheckingEnrollment.value, isTrue);
      },
    );
  });

  group('Blood Donation Request Model & Null Safety Tests', () {
    test(
      'BloodDonationRequest safely handles empty and null json fields without crashing',
      () {
        final emptyJson = <String, dynamic>{};
        final model = BloodDonationRequest.fromJson(emptyJson);

        expect(model.id, isNull);
        expect(model.patientName, equals(''));
        expect(model.bloodGroup, equals(''));
        expect(model.hospital, equals(''));
        expect(model.contactPerson, equals(''));
        expect(model.contactNumber, equals(''));
        expect(model.urgency, equals('normal'));
        expect(model.status, equals('open'));
        expect(model.unitsRequired, equals(1));
      },
    );

    test('BloodDonationRequest correctly parses real backend fields', () {
      final json = {
        'id': 14,
        'patient_name': 'Aisha Rahman',
        'blood_group': 'B+',
        'units_required': 2,
        'hospital': 'MIMS Hospital Calicut',
        'contact_person': 'Rahman K',
        'contact_number': '+919876543210',
        'urgency': 'critical',
        'status': 'open',
        'needed_before': '2026-09-18',
        'notes': 'Post-operative urgent blood requirement',
        'created_at': '2026-09-12T10:30:00.000Z',
        'updated_at': '2026-09-13T08:15:00.000Z',
        'created_by': 'admin123',
      };
      final model = BloodDonationRequest.fromJson(json);

      expect(model.id, equals(14));
      expect(model.patientName, equals('Aisha Rahman'));
      expect(model.bloodGroup, equals('B+'));
      expect(model.unitsRequired, equals(2));
      expect(model.hospital, equals('MIMS Hospital Calicut'));
      expect(model.contactPerson, equals('Rahman K'));
      expect(model.contactNumber, equals('+919876543210'));
      expect(model.urgency, equals('critical'));
      expect(model.status, equals('open'));
      expect(model.neededBefore, equals('2026-09-18'));
      expect(model.notes, equals('Post-operative urgent blood requirement'));
      expect(model.createdAt, isNotNull);
      expect(model.createdBy, equals('admin123'));
    });
  });
}
