import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/attendance_controller.dart';
import 'package:nss_new/view/home_screen.dart';
import 'package:nss_new/view/attendance/view_attendance_screen.dart';
import 'package:nss_new/view/attendance/record_attendance_screen.dart';
import 'package:nss_new/model/user_model.dart';

class ManageAttendanceScreen extends StatefulWidget {
  const ManageAttendanceScreen({super.key});

  @override
  State<ManageAttendanceScreen> createState() => _ManageAttendanceScreenState();
}

class _ManageAttendanceScreenState extends State<ManageAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final AttendanceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.fetchBatches();
      controller.getUsers();
      controller.getPrograms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(
            () => const RecordAttendanceScreen(),
          )?.then((_) => controller.getUsers());
        },
        backgroundColor: cs.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Record Attendance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top search and back row
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 16.0,
                top: 12.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: cs.primary),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.outline.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          controller.onSearchTextChanged(val);
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Search by volunteer name or admission ID...',
                          hintStyle: tt.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: cs.onSurface.withOpacity(0.6),
                            size: 20,
                          ),
                          suffixIcon:
                              controller.searchController.text.isNotEmpty ||
                                  _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: cs.onSurface.withOpacity(0.6),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.onSearchTextChanged('');
                                  },
                                )
                              : const SizedBox.shrink(),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Attendance',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track volunteer participation, logs and service hours across all programs.',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Filter & Export Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  // Batch Dropdown
                  Expanded(
                    child: Obx(() {
                      final batches = controller.batchSummaries
                          .map((b) => b.batch.trim())
                          .where((b) => b.isNotEmpty)
                          .toSet()
                          .toList();
                      batches.sort((a, b) {
                        final intA = int.tryParse(a);
                        final intB = int.tryParse(b);
                        if (intA != null && intB != null) {
                          return intB.compareTo(intA);
                        }
                        return b.compareTo(a);
                      });

                      final selected = controller.selectedBatch.value.trim();
                      final effectiveVal =
                          (selected.isNotEmpty && batches.contains(selected))
                          ? selected
                          : (batches.isNotEmpty ? batches.first : null);

                      final isBatchLoading = controller.isBatchLoading.value;

                      return DropdownButtonFormField<String>(
                        value: effectiveVal,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: cs.primary),
                        hint: Text(
                          isBatchLoading
                              ? 'Loading batches...'
                              : 'Select Batch',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Batch',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: cs.outline.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: cs.outline.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: cs.primary,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: cs.onPrimary,
                        ),
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        dropdownColor: cs.onPrimary,
                        borderRadius: BorderRadius.circular(12),
                        items: batches
                            .map(
                              (b) => DropdownMenuItem<String>(
                                value: b,
                                child: Text(
                                  b,
                                  style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: batches.isEmpty
                            ? null
                            : (val) {
                                if (val != null) {
                                  controller.filterByBatch(val);
                                }
                              },
                      );
                    }),
                  ),
                  const SizedBox(width: 10),

                  // Export Button
                  Obx(() {
                    final exporting = controller.isExporting.value;
                    return ElevatedButton.icon(
                      onPressed: exporting
                          ? null
                          : () => controller.exportAttendanceExcel(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: cs.primary.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: exporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.file_download_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                      label: Text(
                        exporting ? 'Exporting...' : 'Export Attendance',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Volunteer List Section
            Expanded(
              child: Obx(() {
                final isLoading =
                    controller.isLoading.value ||
                    controller.isBatchLoading.value;
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.searchList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 48,
                          color: cs.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.selectedBatch.value.isNotEmpty
                              ? 'No volunteers found for batch ${controller.selectedBatch.value}'
                              : 'No volunteers found',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchBatches();
                    await controller.getUsers();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 4,
                      bottom: 90,
                    ),
                    itemCount: controller.searchList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final v = controller.searchList[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: cs.onPrimary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            final userObj = Users(
                              admissionNo: v.admissionNo,
                              name: v.name,
                              department: v.department,
                              role: v.role,
                            );
                            Get.to(() => AttendanceScreen(volunteer: userObj));
                          },
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: cs.primary.withOpacity(0.12),
                            child: Text(
                              (v.name?.isNotEmpty ?? false)
                                  ? v.name![0].toUpperCase()
                                  : '?',
                              style: tt.titleMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            v.name ?? '',
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            "Admission No: ${v.admissionNo ?? ''}\n${v.department?.category ?? ''} ${v.department?.name ?? ''}",
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: cs.onSurface.withOpacity(0.4),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
