import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/blood_requirement_controller.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/view/blood_requirement_details_sheet.dart';
import 'package:nss_new/view/manage_blood_requirement_screen.dart';
import 'package:nss_new/view/program/programs_screen.dart';
import 'package:nss_new/controller/program_controller.dart';
import 'package:nss_new/model/programs_model.dart';

class TestBloodRequirementController extends BloodRequirementController {
  @override
  Future<void> fetchBloodRequests({String? bloodGroup, String? status}) async {
    // In-memory test stub: do not wipe requirements
  }
}

class TestProgramListController extends ProgramListController {
  @override
  void getPrograms({String? status}) {
    // In-memory test stub: do not wipe programsList
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('1. Requirement Registry - Volunteer Blood Group Filter Tests', () {
    testWidgets('Volunteers can filter requirements by blood group and see All Blood Groups', (tester) async {
      final user = Users(
        name: 'Volunteer User',
        admissionNo: 'V100',
        role: 'vol',
      );
      LocalStorage().writeSession(user: user, token: 'fake_tok', role: 'vol');

      final bloodController = Get.put<BloodRequirementController>(TestBloodRequirementController());
      bloodController.requirements.assignAll([
        BloodDonationRequest(
          id: 1,
          patientName: 'John Doe',
          bloodGroup: 'A+',
          hospital: 'Medical College',
          status: 'pending',
          urgency: 'normal',
        ),
        BloodDonationRequest(
          id: 2,
          patientName: 'Jane Smith',
          bloodGroup: 'O+',
          hospital: 'City Hospital',
          status: 'pending',
          urgency: 'urgent',
        ),
      ]);

      await tester.pumpWidget(
        GetMaterialApp(
          home: const ManageBloodRequirementScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "All Blood Groups" default state exists
      expect(find.text('All Blood Groups'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);

      // Verify volunteer does NOT see the FAB (Add Blood Requirement)
      expect(find.byType(FloatingActionButton), findsNothing);

      // Filter by A+
      bloodController.selectedBloodGroup.value = 'A+';
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);

      // Filter by blood group with no matching requirements
      bloodController.selectedBloodGroup.value = 'AB-';
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsNothing);
      expect(find.text('Jane Smith'), findsNothing);
      expect(find.text('No blood requirements for blood group AB-'), findsOneWidget);
      expect(find.text('Reset Filters'), findsOneWidget);

      // Reset
      await tester.tap(find.text('Reset Filters'));
      await tester.pumpAndSettle();

      expect(bloodController.selectedBloodGroup.value, '');
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });
  });

  group('2. Active Blood Requirement - Volunteer View Tests', () {
    testWidgets('Volunteer view displays informational status without dropdown arrow/action', (tester) async {
      final user = Users(
        name: 'Volunteer User',
        admissionNo: 'V100',
        role: 'vol',
      );
      LocalStorage().writeSession(user: user, token: 'fake_tok', role: 'vol');

      final req = BloodDonationRequest(
        id: 1,
        patientName: 'John Doe',
        bloodGroup: 'A+',
        hospital: 'Medical College',
        status: 'pending',
        urgency: 'normal',
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => BloodRequirementDetailsSheet.show(context, req),
                child: const Text('Open Details'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      // Volunteer should see the section header
      expect(find.text('Requirement Status'), findsOneWidget);
      // Volunteer should see informational status text
      expect(find.text('Pending / Open'), findsOneWidget);
      // Volunteer should NOT see dropdown arrow button
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
      // Volunteer should NOT have an active DropdownButton for status
      expect(find.byType(DropdownButton<String>), findsNothing);
    });

    testWidgets('Program Officer / Admin retains status dropdown and arrow', (tester) async {
      final user = Users(
        name: 'Officer User',
        admissionNo: 'PO100',
        role: 'po',
      );
      LocalStorage().writeSession(user: user, token: 'fake_tok', role: 'po');

      final req = BloodDonationRequest(
        id: 1,
        patientName: 'John Doe',
        bloodGroup: 'A+',
        hospital: 'Medical College',
        status: 'pending',
        urgency: 'normal',
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => BloodRequirementDetailsSheet.show(context, req),
                child: const Text('Open Details'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      // Authorized user sees Requirement Status
      expect(find.text('Requirement Status'), findsOneWidget);
      // Authorized user sees dropdown button with dropdown arrow
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });
  });

  group('3. Programs / Total Hours Statistics Tests', () {
    testWidgets('Both Programs and Total Hours remain fully visible even with long values on smaller screen width', (tester) async {
      // Set a smaller screen size (320px width)
      tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final user = Users(
        name: 'PO Admin',
        admissionNo: 'PO100',
        role: 'po',
      );
      LocalStorage().writeSession(user: user, token: 'fake_tok', role: 'po');

      final progController = Get.put<ProgramListController>(TestProgramListController());
      progController.programsList.assignAll([
        Program(id: 1, name: 'Prog 1', duration: 1250),
        Program(id: 2, name: 'Prog 2', duration: 350),
      ]);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ProgramsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check both labels and values are present and rendered without exceptions
      expect(find.text('Programs'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Total Hours'), findsOneWidget);
      expect(find.text('1600 hrs'), findsOneWidget);

      // Verify no RenderFlex overflow error was triggered
      expect(tester.takeException(), isNull);
    });
  });

  group('4. Custom Snackbar Tests', () {
    testWidgets('CustomWidgets.showSnackBar does not crash and supports all semantic types', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      CustomWidgets.showSnackBar('Success', 'Operation succeeded');
                    },
                    child: const Text('Show Success'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      CustomWidgets.showSnackBar('Error', 'Operation failed with critical issue');
                    },
                    child: const Text('Show Error'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      CustomWidgets.showSnackBar('Warning', 'Please check input');
                    },
                    child: const Text('Show Warning'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Test invoking without crashing
      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Show Error'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Show Warning'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
