import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/attendance_controller.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';

class RecordAttendanceScreen extends StatefulWidget {
  const RecordAttendanceScreen({super.key});

  @override
  State<RecordAttendanceScreen> createState() => _RecordAttendanceScreenState();
}

class _RecordAttendanceScreenState extends State<RecordAttendanceScreen> {
  late final AttendanceController controller;

  String _searchQuery = '';
  int? _selectedProgramId;
  DateTime? _selectedDate;
  final TextEditingController _hoursController = TextEditingController();
  bool _isAutoPopulated = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());
    controller.selectedVolList.clear();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayStr = date.day.toString().padLeft(2, '0');
    return "${months[date.month - 1]} $dayStr, ${date.year}";
  }

  void _markAttendance() {
    if (controller.selectedVolList.isEmpty) {
      CustomWidgets.showSnackBar(
        'Selection Required',
        'Please select at least one volunteer to mark attendance.',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }
    if (_selectedProgramId == null) {
      CustomWidgets.showSnackBar(
        'Required Field Missing',
        'Please select a program.',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }
    if (_selectedDate == null) {
      CustomWidgets.showSnackBar(
        'Required Field Missing',
        'Please select a service date.',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }
    final hrsStr = _hoursController.text.trim();
    if (hrsStr.isEmpty) {
      CustomWidgets.showSnackBar(
        'Required Field Missing',
        'Please specify the hours served.',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }
    final int? hrs = int.tryParse(hrsStr);
    if (hrs == null || hrs <= 0) {
      CustomWidgets.showSnackBar(
        'Invalid Value',
        'Please enter a valid positive whole number for hours served.',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }

    controller.programId = _selectedProgramId!;
    controller.date = _selectedDate;
    controller.dateController.text = _selectedDate != null
        ? _formatDate(_selectedDate!)
        : '';
    controller.durationController.text = hrsStr;

    if (controller.onSubmitAttendanceValidation()) {
      CustomWidgets().showConfirmationDialog(
        title: "Submit Attendance",
        message:
            "Are you sure you want to submit attendance for ${controller.selectedVolList.length} volunteers?",
        onConfirm: () => controller.onSubmitAttendance(),
        data: Obx(
          () => controller.isSubmittingAttendance.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
                )
              : const Text("Confirm", style: TextStyle(color: Colors.red)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Record Attendance',
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.usersList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get volunteers sorted alphabetically
        final List<Volunteer> sortedVolunteers = List<Volunteer>.from(
          controller.usersList,
        )..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

        // Filter based on search query
        final List<Volunteer> filteredVolunteers = sortedVolunteers.where((v) {
          final nameMatch =
              v.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false;
          final idMatch =
              v.admissionNo?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false;
          return nameMatch || idMatch;
        }).toList();

        final bool isAllSelected =
            filteredVolunteers.isNotEmpty &&
            filteredVolunteers.every(
              (v) => controller.selectedVolList.any(
                (selected) => selected.admissionNo == v.admissionNo,
              ),
            );

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Text(
                  'Log volunteer service hours for institutional community programs',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Select Volunteers Header
                Text(
                  'Select Volunteers',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Select All Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isAllSelected) {
                            for (var v in filteredVolunteers) {
                              controller.selectedVolList.removeWhere(
                                (e) => e.admissionNo == v.admissionNo,
                              );
                            }
                          } else {
                            for (var v in filteredVolunteers) {
                              final exists = controller.selectedVolList.any(
                                (e) => e.admissionNo == v.admissionNo,
                              );
                              if (!exists) {
                                controller.selectedVolList.add(v);
                              }
                            }
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isAllSelected,
                            activeColor: cs.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  for (var v in filteredVolunteers) {
                                    final exists = controller.selectedVolList
                                        .any(
                                          (e) => e.admissionNo == v.admissionNo,
                                        );
                                    if (!exists) {
                                      controller.selectedVolList.add(v);
                                    }
                                  }
                                } else {
                                  for (var v in filteredVolunteers) {
                                    controller.selectedVolList.removeWhere(
                                      (e) => e.admissionNo == v.admissionNo,
                                    );
                                  }
                                }
                              });
                            },
                          ),
                          Text(
                            'Select All',
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.selectedVolList.length} selected',
                        style: tt.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.outline.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name or id...',
                      hintStyle: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: cs.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
                const SizedBox(height: 16),

                // List of Volunteers
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outline.withOpacity(0.3)),
                    color: cs.outline.withOpacity(0.03),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: filteredVolunteers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'No volunteers found',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredVolunteers.length,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(8.0),
                          itemBuilder: (context, index) {
                            final v = filteredVolunteers[index];
                            final isSelected = controller.selectedVolList.any(
                              (selected) =>
                                  selected.admissionNo == v.admissionNo,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primary.withOpacity(0.04)
                                    : cs.onPrimary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? cs.primary
                                      : cs.outline.withOpacity(0.3),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: CheckboxListTile(
                                value: isSelected,
                                activeColor: cs.primary,
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      controller.selectedVolList.add(v);
                                    } else {
                                      controller.selectedVolList.removeWhere(
                                        (e) => e.admissionNo == v.admissionNo,
                                      );
                                    }
                                  });
                                },
                                title: Text(
                                  v.name ?? '',
                                  style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  v.admissionNo ?? '',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurface.withOpacity(0.5),
                                  ),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),

                // Select Program
                Text(
                  'Select Program',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedProgramId,
                  isExpanded: true,
                  menuMaxHeight: 280,
                  hint: const Text('Choose NSS Program'),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary, width: 1.5),
                    ),
                  ),
                  selectedItemBuilder: (context) {
                    final validProgs = controller.programsList
                        .where(
                          (prog) =>
                              prog.date != null &&
                              !prog.date!.isAfter(DateTime.now()),
                        )
                        .toList();
                    return validProgs.map((prog) {
                      return Text(
                        prog.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      );
                    }).toList();
                  },
                  items: controller.programsList
                      .where(
                        (prog) =>
                            prog.date != null &&
                            !prog.date!.isAfter(DateTime.now()),
                      )
                      .map(
                        (prog) => DropdownMenuItem<int>(
                          value: prog.id,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  prog.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${prog.date != null ? _formatDate(prog.date!) : ''}${prog.duration != null && prog.duration! > 0 ? ' • ${prog.duration} hours' : ''}",
                                  style: tt.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: cs.onSurface.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProgramId = val;
                      if (val != null) {
                        final prog = controller.programsList.firstWhereOrNull(
                          (p) => p.id == val,
                        );
                        if (prog != null) {
                          if (prog.date != null) {
                            _selectedDate = prog.date;
                          }
                          if (prog.duration != null && prog.duration! > 0) {
                            _hoursController.text = prog.duration.toString();
                          }
                          _isAutoPopulated = true;
                        }
                      } else {
                        _isAutoPopulated = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Service Date
                Text(
                  'Service Date',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Select a program first'
                            : _formatDate(_selectedDate!),
                        style: tt.bodyMedium?.copyWith(
                          color: _selectedDate == null
                              ? cs.onSurface.withValues(alpha: 0.5)
                              : cs.onSurface,
                          fontWeight: _selectedDate != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      Icon(
                        Icons.lock_outline_rounded,
                        color: cs.onSurface.withOpacity(0.45),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Hours Served
                Text(
                  'Hours Served',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _hoursController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. 3',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary, width: 1.5),
                    ),
                  ),
                  style: tt.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Note: standard sessions range from 1 to 6 hours',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: cs.outline),
                        ),
                        child: Text(
                          'Cancel',
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _markAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Mark Attendance',
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}
