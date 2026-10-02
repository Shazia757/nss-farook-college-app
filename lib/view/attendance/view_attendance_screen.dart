import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/navbar.dart';
import 'package:nss_new/controller/attendance_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/model/attendance_model.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/view/home_screen.dart';

class AttendanceScreen extends StatefulWidget {
  final Users? volunteer;
  const AttendanceScreen({super.key, this.volunteer});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _searchQuery = '';
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
      final admissionNo = widget.volunteer != null
          ? widget.volunteer!.admissionNo ?? ''
          : LocalStorage().readUser().admissionNo ?? '';
      controller.getAttendance(admissionNo);
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
    final role = LocalStorage().readUser().role;

    return Scaffold(
      backgroundColor: cs.surface,
      bottomNavigationBar: widget.volunteer != null
          ? null
          : role == 'po' || role == 'sec'
          ? null
          : const CustomBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Obx(() {
          if (controller.isAttendanceLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredRecords = controller.attendanceList.where((p) {
            final titleMatch =
                p.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false;
            return titleMatch;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation & Search Bar
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
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search records...',
                            hintStyle: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: cs.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: cs.onSurface.withOpacity(0.6),
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
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

              // Title and Subtitle Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.volunteer != null
                          ? widget.volunteer!.name ?? 'Attendance'
                          : 'Attendance History',
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.volunteer != null
                          ? 'Admission No: ${widget.volunteer!.admissionNo} • ${widget.volunteer!.department?.category ?? ""} ${widget.volunteer!.department?.name ?? ""}'
                          : 'Review your participation in NSS activities and service programs.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Scrollable Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final admissionNo = widget.volunteer != null
                        ? widget.volunteer!.admissionNo ?? ''
                        : LocalStorage().readUser().admissionNo ?? '';
                    await controller.getAttendance(admissionNo);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Outlined Stat Cards Row
                        if (role != 'vol') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatCard(
                                context,
                                'TOTAL PROGRAMS',
                                '${controller.totalPrograms.value} events',
                                cs,
                                tt,
                              ),
                              const SizedBox(width: 8),

                              _buildStatCard(
                                context,
                                'TOTAL HOURS',
                                '${controller.totalHours.value} hours',
                                cs,
                                tt,
                              ),
                              const SizedBox(width: 8),
                              _buildStatCard(
                                context,
                                'AVG. HOURS',
                                controller.totalPrograms.value > 0
                                    ? '${(controller.totalHours.value / controller.totalPrograms.value).toStringAsFixed(1)} hrs/event'
                                    : '0.0 hrs/event',
                                cs,
                                tt,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Section Heading: Program History
                        Text(
                          'Program History',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // History Cards List
                        if (filteredRecords.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 40.0,
                              ),
                              child: Text(
                                'No programs found',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredRecords.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final record = filteredRecords[index];
                              final dateStr = record.date != null
                                  ? DateFormat.yMMMd().format(record.date!)
                                  : 'N/A';
                              final admissionNo = widget.volunteer != null
                                  ? widget.volunteer!.admissionNo ?? ''
                                  : LocalStorage().readUser().admissionNo ?? '';
                              return _buildHistoryCard(
                                context: context,
                                record: record,
                                title: record.name ?? '',
                                markedBy: record.markedBy != null
                                    ? 'Marked by: ${record.markedBy}'
                                    : 'Log Recorded',
                                date: dateStr,
                                hours: record.hours?.toString() ?? '0',
                                cs: cs,
                                tt: tt,
                                admissionNo: admissionNo,
                              );
                            },
                          ),
                        const SizedBox(height: 24),

                        // Participation Warning/Note Card
                        if (widget.volunteer == null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.secondary.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(color: cs.secondary, width: 4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: cs.secondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Note on Participation',
                                      style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: cs.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Regular attendance is vital for the NSS Award and Certificate eligibility. Please ensure your presence is marked by the Unit Secretary during every program. If you find any discrepancies, contact your Program Officer.',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurface.withOpacity(0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 8.5,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required BuildContext context,
    required Attendance record,
    required String title,
    required String markedBy,
    required String date,
    required String hours,
    required ColorScheme cs,
    required TextTheme tt,
    required String admissionNo,
  }) {
    final role = LocalStorage().readUser().role;
    final isStaffOrSec = role == 'sec' || role == 'po' || role != 'vol';
    final parts = date.split(' ');
    String month = 'NSS';
    String day = '--';
    if (parts.isNotEmpty) {
      if (parts[0].length >= 3) {
        month = parts[0].substring(0, 3).toUpperCase();
      } else {
        month = parts[0].toUpperCase();
      }
    }
    if (parts.length > 1) {
      day = parts[1].replaceAll(',', '');
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: isStaffOrSec
            ? () {
                _showAttendanceOptionsBottomSheet(context, record, admissionNo);
              }
            : null,
        onTap: isStaffOrSec
            ? () {
                _showAttendanceOptionsBottomSheet(context, record, admissionNo);
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.6)),
          ),
          child: Row(
            children: [
              // Date block on Left
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day,
                      style: tt.titleLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      month,
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Title and Location on Right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            markedBy,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (role != 'vol') ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$hours hrs',
                    style: tt.labelMedium?.copyWith(
                      color: cs.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.more_vert,
                  size: 18,
                  color: cs.onSurface.withOpacity(0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceOptionsBottomSheet(
    BuildContext context,
    Attendance record,
    String admissionNo,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Section label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Attendance Actions',
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Update action
                  _attendanceActionTile(
                    context: sheetContext,
                    icon: Icons.edit_rounded,
                    title: 'Update Attendance',
                    subtitle: 'Change the recorded hours',
                    iconColor: cs.primary,
                    backgroundColor: cs.primary.withOpacity(0.08),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showUpdateHoursDialog(context, record, admissionNo);
                    },
                  ),

                  const SizedBox(height: 10),

                  // Delete action
                  _attendanceActionTile(
                    context: sheetContext,
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Attendance',
                    subtitle: 'Remove this attendance record',
                    iconColor: cs.error,
                    backgroundColor: cs.error.withOpacity(0.08),
                    titleColor: cs.error,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showDeleteConfirmationDialog(
                        context,
                        record,
                        admissionNo,
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _attendanceActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurface.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateHoursDialog(
    BuildContext context,
    Attendance record,
    String admissionNo,
  ) {
    final cs = Theme.of(context).colorScheme;
    final hoursTextController = TextEditingController(
      text: (record.hours ?? 0).toString(),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Update Attendance"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Program: ${record.name ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hoursTextController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Hours",
                hintText: "Enter updated duration in hours",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.hourglass_bottom_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newHours = int.tryParse(hoursTextController.text.trim());
              if (newHours == null || newHours < 0) {
                CustomWidgets.showSnackBar(
                  'Invalid Input',
                  'Please enter a valid number of hours',
                );
                return;
              }
              if (record.id == null) {
                CustomWidgets.showSnackBar(
                  'Error',
                  'Invalid attendance record ID',
                );
                return;
              }
              controller.updateAttendanceRecord(
                record.id!,
                newHours,
                admissionNo,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Obx(
              () => controller.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Attendance record,
    String admissionNo,
  ) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Attendance"),
        content: Text(
          "Are you sure you want to delete attendance for \"${record.name ?? 'this program'}\"?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (record.id == null) {
                CustomWidgets.showSnackBar(
                  'Error',
                  'Invalid attendance record ID',
                );
                return;
              }
              controller.deleteAttendance(
                record.id!,
                volunteerAdmn: admissionNo,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Obx(
              () => controller.isDeleteButtonLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
