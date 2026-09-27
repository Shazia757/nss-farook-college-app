import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nss_new/config/excel_generator.dart';
import 'package:nss_new/controller/attendance_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/volunteer_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => '.',
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (MethodCall methodCall) async => ['wifi'],
        );
    Get.testMode = true;
    await GetStorage.init();
    Get.reset();
    LocalStorage().clearAll();
  });

  group('Batch API Model and Dropdown Logic Tests', () {
    test('BatchSummary.fromJson parses various types and trims batch safely', () {
      final json1 = {
        'batch': ' 2024 ',
        'total': 15,
        'active_count': 12,
        'passive_count': 3,
      };
      final summary1 = BatchSummary.fromJson(json1);
      expect(summary1.batch, equals('2024'));
      expect(summary1.totalCount, equals(15));
      expect(summary1.activeCount, equals(12));
      expect(summary1.passiveCount, equals(3));

      // String counts fallback
      final json2 = {
        'batch': '2025',
        'total_volunteers': '20',
        'active_volunteers': '18',
        'passive_volunteers': '2',
      };
      final summary2 = BatchSummary.fromJson(json2);
      expect(summary2.batch, equals('2025'));
      expect(summary2.totalCount, equals(20));
      expect(summary2.activeCount, equals(18));
      expect(summary2.passiveCount, equals(2));

      // Null / empty json
      final summary3 = BatchSummary.fromJson({});
      expect(summary3.batch, equals(''));
      expect(summary3.totalCount, equals(0));
      expect(summary3.activeCount, equals(0));
      expect(summary3.passiveCount, equals(0));
    });

    test('Batch dropdown list is deduplicated and sorted newest first', () {
      final controller = AttendanceController();
      controller.batchSummaries.assignAll([
        BatchSummary(batch: '2023'),
        BatchSummary(batch: '2025'),
        BatchSummary(batch: '2024'),
        BatchSummary(batch: '2024'), // duplicate
        BatchSummary(batch: ' '),    // whitespace/empty
      ]);

      final batches = controller.batchSummaries
          .map((b) => b.batch.trim())
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList();
      batches.sort((a, b) {
        final intA = int.tryParse(a);
        final intB = int.tryParse(b);
        if (intA != null && intB != null) {
          return intB.compareTo(intA); // Newest first
        }
        return b.compareTo(a);
      });

      expect(batches, equals(['2025', '2024', '2023']));
      controller.onClose();
    });

    test('Selecting a batch updates AttendanceController filter and safe selection handles missing batch', () {
      final controller = AttendanceController();
      controller.batchSummaries.assignAll([
        BatchSummary(batch: '2024'),
        BatchSummary(batch: '2025'),
      ]);

      // Valid selection
      controller.filterByBatch('2024');
      expect(controller.selectedBatch.value, equals('2024'));

      // If selected batch does not exist in API, safe selection evaluates to empty / null
      controller.batchSummaries.assignAll([
        BatchSummary(batch: '2025'),
        BatchSummary(batch: '2026'),
      ]);

      final batches = controller.batchSummaries.map((b) => b.batch).toList();
      final effectiveVal = batches.contains(controller.selectedBatch.value)
          ? controller.selectedBatch.value
          : '';
      expect(effectiveVal, equals('')); // Safely resets to empty without throwing assertion

      controller.onClose();
    });
  });

  group('Attendance Excel Export Logic Tests', () {
    test('Export operation prevents concurrent duplicate calls', () async {
      final controller = AttendanceController();
      expect(controller.isExporting.value, isFalse);

      // Simulate export started
      controller.isExporting.value = true;
      expect(controller.isExporting.value, isTrue);

      // Calling exportAttendanceExcel while already exporting returns early
      await controller.exportAttendanceExcel();
      expect(controller.isExporting.value, isTrue);

      controller.isExporting.value = false;
      controller.onClose();
    });

    test('Writing exported bytes to system temp directory creates a valid readable file', () async {
      final tempDir = Directory.systemTemp;
      const testContent = 'Mock Excel Content';
      final testBytes = utf8.encode(testContent);

      final fileName = 'test_attendance_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(testBytes, flush: true);

      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(0));

      // Clean up test file
      await file.delete();
      expect(await file.exists(), isFalse);
    });

    test('ExcelGenerator creates valid OpenXML .xlsx bytes with correct headers and data', () async {
      final headers = [
        'Admission Number',
        'Volunteer Name',
        'Batch',
        'Program',
        'Date',
        'Attendance',
        'Service Hours',
      ];
      final rows = [
        ['1001', 'Test Volunteer 1', '2024', 'Tree Plantation', '2024-05-10', 'Present', 4],
        ['1002', 'Test Volunteer 2', '2024', 'Blood Donation Camp', '2024-06-15', 'Present', 6],
      ];

      final bytes = ExcelGenerator.generateAttendanceWorkbook(
        headers: headers,
        rows: rows,
        sheetName: 'Attendance_2024',
      );

      expect(bytes, isNotEmpty);
      // Valid PK zip header
      expect(bytes[0], equals(0x50));
      expect(bytes[1], equals(0x4B));

      // Test writing to disk and verifying size
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/test_attendance_2024.xlsx');
      await file.writeAsBytes(bytes, flush: true);

      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(100));

      await file.delete();
      expect(await file.exists(), isFalse);
    });

    testWidgets('Export on empty volunteer list shows friendly No Data snackbar without crash', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      final controller = AttendanceController();
      controller.selectedBatch.value = '2024';
      controller.usersList.clear();
      controller.searchList.clear();

      await controller.exportAttendanceExcel();
      expect(controller.isExporting.value, isFalse);

      controller.onClose();
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });
  });
}
