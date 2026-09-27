import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nss_new/config/urls.dart';
import 'package:nss_new/controller/account_controller.dart';
import 'package:nss_new/database/local_storage.dart';

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

  group('Legal & Configuration Details Tests', () {
    test('Configured URLs and contact information are non-empty and valid', () {
      expect(Details.appVersion, isNotEmpty);
      expect(Details.contactEmail, contains('@'));
      expect(Details.contactNo1, isNotEmpty);
      expect(Details.contactNo2, isNotEmpty);
      expect(Details.collegeWebsite, startsWith('http'));
      expect(Details.privacyPolicyUrl, startsWith('http'));
      expect(Details.termsAndConditionsUrl, startsWith('http'));
    });
  });

  group('AccountController Staff Password Reset Tests', () {
    testWidgets('Validation fails if new password is empty, short, or mismatched', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      final controller = AccountController();

      // Empty
      controller.newPassController.text = '';
      controller.confirmPassController.text = '';
      expect(controller.onResetPassValidation(), isFalse);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Short
      controller.newPassController.text = '12345';
      controller.confirmPassController.text = '12345';
      expect(controller.onResetPassValidation(), isFalse);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Mismatched
      controller.newPassController.text = 'password123';
      controller.confirmPassController.text = 'password999';
      expect(controller.onResetPassValidation(), isFalse);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Valid
      controller.newPassController.text = 'validPassword123';
      controller.confirmPassController.text = 'validPassword123';
      expect(controller.onResetPassValidation(), isTrue);

      controller.onClose();
      await tester.pumpAndSettle();
    });

    test('clearPasswordFields clears sensitive text controllers', () {
      final controller = AccountController();

      controller.oldpasswordController.text = 'secretOld';
      controller.newPassController.text = 'secretNew';
      controller.confirmPassController.text = 'secretNew';

      controller.clearPasswordFields();

      expect(controller.oldpasswordController.text, isEmpty);
      expect(controller.newPassController.text, isEmpty);
      expect(controller.confirmPassController.text, isEmpty);

      controller.onClose();
    });
  });
}
