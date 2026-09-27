import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/attendance_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/config/excel_generator.dart';
import 'package:share_plus/share_plus.dart';

class AttendanceController extends GetxController {
  final Api _api = Api();

  TextEditingController programNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  RxList<Volunteer> usersList = <Volunteer>[].obs;
  RxList<Volunteer> searchList = <Volunteer>[].obs;
  RxList<Volunteer> selectedVolList = <Volunteer>[].obs;
  RxList<Attendance> attendanceList = <Attendance>[].obs;
  RxList<Program> programsList = <Program>[].obs;

  RxInt sortColumnIndex = 0.obs;
  RxBool isAscending = true.obs;
  int? programId;

  RxBool isLoading = false.obs;
  RxBool isDeleteButtonLoading = false.obs;
  RxBool isAttendanceLoading = false.obs;
  RxBool isProgramLoading = false.obs;
  RxBool isSubmittingAttendance = false.obs;

  RxInt totalHours = 0.obs;
  RxInt totalPrograms = 0.obs;
  DateTime? date;

  RxList<BatchSummary> batchSummaries = <BatchSummary>[].obs;
  RxString selectedBatch = ''.obs;
  RxBool isBatchLoading = false.obs;
  RxBool isExporting = false.obs;

  @override
  void onReady() {
    super.onReady();
    fetchBatches();
    getUsers();
    getPrograms();
  }

  @override
  void onClose() {
    programNameController.dispose();
    dateController.dispose();
    durationController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchBatches() async {
    if (isClosed) return;
    isBatchLoading.value = true;
    try {
      final list = await _api.getBatches();
      if (isClosed) return;
      if (list != null && list.isNotEmpty) {
        batchSummaries.assignAll(list);
        final validBatches = batchSummaries
            .map((b) => b.batch.trim())
            .where((b) => b.isNotEmpty)
            .toSet()
            .toList();
        validBatches.sort((a, b) {
          final intA = int.tryParse(a);
          final intB = int.tryParse(b);
          if (intA != null && intB != null) return intB.compareTo(intA);
          return b.compareTo(a);
        });

        if (validBatches.isNotEmpty &&
            (selectedBatch.value.isEmpty ||
                !validBatches.contains(selectedBatch.value))) {
          selectedBatch.value = validBatches.first;
          getUsers(batch: selectedBatch.value);
        }
      }
    } catch (e) {
      log('Error fetching batches in AttendanceController: $e');
    } finally {
      if (!isClosed) {
        isBatchLoading.value = false;
      }
    }
  }

  void filterByBatch(String batch) {
    if (isClosed) return;
    selectedBatch.value = batch.trim();
    getUsers(batch: selectedBatch.value);
  }

  void getUsers({String? batch}) {
    if (isClosed) return;
    isLoading.value = true;
    final batchFilter = (batch ?? selectedBatch.value).trim();
    _api
        .getVolunteers(batch: batchFilter.isNotEmpty ? batchFilter : null)
        .then((value) {
          if (isClosed) return;
          var data = value?.data
              ?.where((element) => element.role != 'po')
              .toList() ?? [];
          if (batchFilter.isNotEmpty) {
            data = data
                .where((v) => (v.batch ?? '').trim() == batchFilter)
                .toList();
          }
          usersList.assignAll(data);
          if (searchController.text.trim().isNotEmpty) {
            onSearchTextChanged(searchController.text.trim());
          } else {
            searchList.assignAll(usersList);
            searchList.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
          }
          isLoading.value = false;
        })
        .catchError((_) {
          if (!isClosed) isLoading.value = false;
        });
  }

  Future<void> exportAttendanceExcel({int? programId}) async {
    if (isClosed || isExporting.value) return;
    isExporting.value = true;

    final batch = selectedBatch.value.trim();

    try {
      CustomWidgets.showSnackBar(
        'Exporting',
        'Generating attendance report for ${batch.isNotEmpty ? "batch $batch" : "all batches"}...',
        backgroundColor: Colors.blue.shade800,
        icon: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );

      // 1. First, attempt to retrieve attendance records for this batch
      List<Attendance> records = [];
      try {
        final attRes = await _api.getAttendance(
          batch: batch.isNotEmpty ? batch : null,
          programId: programId,
        );
        if (attRes?.attendance != null && attRes!.attendance!.isNotEmpty) {
          records = attRes.attendance!;
        }
      } catch (e) {
        log('Notice: getAttendance query returned: $e');
      }

      // Filter volunteers for the selected batch
      final volsInBatch = usersList
          .where((v) => batch.isEmpty || (v.batch ?? '').trim() == batch)
          .toList();

      // Check if both attendance records and volunteer list are empty
      if (records.isEmpty && volsInBatch.isEmpty) {
        CustomWidgets.showSnackBar(
          'No Data',
          'No attendance records found to export.',
          backgroundColor: Colors.orange.shade800,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        return;
      }

      List<int>? fileBytes;

      // 2. Try the backend export endpoint if available
      try {
        final response = await _api.exportAttendanceExcel(
          batch: batch.isNotEmpty ? batch : null,
          programId: programId,
        );
        if (response != null &&
            response.statusCode == 200 &&
            response.bodyBytes.length >= 4 &&
            response.bodyBytes[0] == 0x50 &&
            response.bodyBytes[1] == 0x4B) {
          // Valid OpenXML ZIP file header
          fileBytes = response.bodyBytes;
        }
      } catch (_) {}

      // 3. If backend didn't supply an Excel binary, generate standard .xlsx workbook locally
      if (fileBytes == null || fileBytes.isEmpty) {
        final headers = [
          'Admission Number',
          'Volunteer Name',
          'Batch',
          'Program',
          'Date',
          'Attendance',
          'Service Hours',
        ];

        final rows = <List<dynamic>>[];
        final volMap = {for (var v in usersList) (v.admissionNo ?? ''): v};

        if (records.isNotEmpty) {
          for (final att in records) {
            final vol = volMap[att.admissionNo ?? ''];
            final dateStr = att.date != null
                ? DateFormat('yyyy-MM-dd').format(att.date!)
                : '';
            rows.add([
              att.admissionNo ?? vol?.admissionNo ?? '',
              vol?.name ?? att.admissionNo ?? 'Volunteer',
              vol?.batch ?? batch,
              att.name ?? 'NSS Activity',
              dateStr,
              'Present',
              att.hours ?? 0,
            ]);
          }
        } else {
          // Populate from volunteers enrolled/active in this batch
          for (final vol in volsInBatch) {
            rows.add([
              vol.admissionNo ?? '',
              vol.name ?? '',
              vol.batch ?? batch,
              'NSS Service',
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
              (vol.isActive ?? true) ? 'Active' : 'Passive',
              0,
            ]);
          }
        }

        fileBytes = ExcelGenerator.generateAttendanceWorkbook(
          headers: headers,
          rows: rows,
          sheetName: 'Attendance_${batch.isNotEmpty ? batch : "All"}',
        );
      }

      if (fileBytes.isEmpty) {
        throw Exception('Failed to generate Excel workbook content.');
      }

      // 4. Save file to system temporary directory
      final tempDir = Directory.systemTemp;
      final sanitizeBatch = batch.isNotEmpty
          ? batch.replaceAll(RegExp(r'[^\w\-]'), '_')
          : 'All';
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'attendance_${sanitizeBatch}_$timestamp.xlsx';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(fileBytes, flush: true);

      // Verify file exists and has size
      if (!await file.exists() || await file.length() == 0) {
        throw Exception('Excel file was not created on device storage.');
      }

      // 5. Open/Share the generated .xlsx file
      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            name: fileName,
          ),
        ],
        subject: 'NSS Attendance Report ($sanitizeBatch)',
      );

      CustomWidgets.showSnackBar(
        'Success',
        'Attendance report generated successfully.',
        backgroundColor: Colors.green.shade800,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    } catch (e) {
      log('Error during attendance export: $e');
      if (!isClosed) {
        CustomWidgets.showSnackBar(
          'Export Failed',
          'Failed to export attendance: $e',
          backgroundColor: Colors.red.shade800,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } finally {
      if (!isClosed) {
        isExporting.value = false;
      }
    }
  }

  Future<void> getPrograms() async {
    if (isClosed) return;
    isProgramLoading.value = true;
    try {
      final value = await _api.programNames();
      if (isClosed) return;
      programsList.assignAll(value?.programs ?? []);
    } catch (e) {
      log('Error loading programs: $e');
    } finally {
      if (!isClosed) {
        isProgramLoading.value = false;
      }
    }
  }

  Future<void> getAttendance(
    String id, {
    String? batch,
    int? programIdFilter,
  }) async {
    if (isClosed) return;
    isAttendanceLoading.value = true;
    try {
      final value = await _api.getAttendance(
        admissionNumber: id,
        batch: batch,
        programId: programIdFilter,
      );
      if (isClosed) return;
      attendanceList.assignAll(value?.attendance ?? []);
      attendanceList.sort(
        (a, b) =>
            (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()),
      );
      totalHours.value = attendanceList.fold(
        0,
        (sum, element) => sum + (element.hours ?? 0),
      );
      totalPrograms.value = attendanceList.length;
    } catch (e) {
      log('Error getting attendance: $e');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
        isAttendanceLoading.value = false;
      }
    }
  }

  bool onSubmitAttendanceValidation() {
    if (selectedVolList.isEmpty) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please select at least one volunteer',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    if (programId == null) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please select a valid program',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    final selectedProg = programsList.firstWhereOrNull((p) => p.id == programId);
    if (selectedProg != null &&
        selectedProg.date != null &&
        selectedProg.date!.isAfter(DateTime.now())) {
      CustomWidgets.showSnackBar(
        'Invalid Operation',
        'Attendance cannot be recorded for upcoming programs',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    if (date == null) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please select a service date',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    if (date!.isAfter(DateTime.now())) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Service date cannot be in the future',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    final hours = int.tryParse(durationController.text.trim()) ?? 0;
    if (hours <= 0) {
      CustomWidgets.showSnackBar(
        'Validation Error',
        'Please enter valid hours served',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    return true;
  }

  Future<void> onSubmitAttendance() async {
    if (!onSubmitAttendanceValidation()) return;
    if (isClosed) return;
    isSubmittingAttendance.value = true;
    int hours = int.tryParse(durationController.text) ?? 0;
    final dateFormatted =
        date != null ? date!.toIso8601String().split('T')[0] : null;

    List<Map<String, dynamic>> list = selectedVolList
        .map((v) => {
          'volunteer': v.admissionNo,
          'hours': hours,
          if (dateFormatted != null) 'date': dateFormatted,
        })
        .toList();

    _api
        .bulkAddAttendance(programId!, list, date: dateFormatted)
        .then((val) {
          if (isClosed) return;
          isSubmittingAttendance.value = false;
          Get.back(); // close confirmation dialog
          if (val?.status ?? false) {
            Get.back(); // return to previous screen
            CustomWidgets.showSnackBar(
              'Success',
              val?.message ?? 'Attendance added successfully',
              backgroundColor: Colors.green.shade800,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            );
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              val?.message ?? 'Failed to add attendance',
              backgroundColor: Colors.red.shade800,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        })
        .catchError((_) {
          if (!isClosed) {
            isSubmittingAttendance.value = false;
            Get.back();
            CustomWidgets.showSnackBar(
              'Error',
              'Failed to add attendance',
              backgroundColor: Colors.red.shade800,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        });
  }

  Future<void> updateAttendanceRecord(
    int attendanceId,
    int hours,
    String volunteerAdmn,
  ) async {
    if (isClosed) return;
    isLoading.value = true;
    _api
        .updateAttendance(attendanceId, hours)
        .then((val) {
          if (isClosed) return;
          isLoading.value = false;
          if (val?.status ?? false) {
            Get.back();
            CustomWidgets.showSnackBar(
              'Success',
              val?.message ?? 'Attendance updated successfully',
            );
            getAttendance(volunteerAdmn);
          } else {
            CustomWidgets.showSnackBar(
              'Error',
              val?.message ?? 'Failed to update attendance',
            );
          }
        })
        .catchError((_) {
          if (!isClosed) isLoading.value = false;
        });
  }

  Future<void> deleteAttendance(int id, {String? volunteerAdmn}) async {
    if (isClosed) return;
    isDeleteButtonLoading.value = true;
    _api
        .deleteAttendance(id)
        .then((value) {
          if (isClosed) return;
          isDeleteButtonLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            CustomWidgets.showSnackBar(
              "Success",
              value?.message ?? "Attendance deleted successfully.",
            );
            if (volunteerAdmn != null) getAttendance(volunteerAdmn);
          } else {
            CustomWidgets.showSnackBar(
              "Error",
              value?.message ?? 'Failed to delete attendance.',
            );
          }
        })
        .catchError((_) {
          if (!isClosed) isDeleteButtonLoading.value = false;
        });
  }

  void onSearchTextChanged(String value) {
    if (isClosed) return;
    if (value.isEmpty) {
      searchController.clear();
      searchList.assignAll(usersList);
    } else {
      final filtered = usersList.where((volunteer) {
        final name = volunteer.name?.toLowerCase() ?? '';
        final admnNo = volunteer.admissionNo ?? '';
        return admnNo.contains(value.toLowerCase()) ||
            name.contains(value.toLowerCase());
      }).toList();

      searchList.assignAll(filtered);
    }
  }
}
