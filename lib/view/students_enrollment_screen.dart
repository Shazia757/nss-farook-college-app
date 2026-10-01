import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/program_controller.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/attendance_model.dart';
import 'package:nss_new/model/enrollment_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentsEnrollmentScreen extends StatefulWidget {
  const StudentsEnrollmentScreen({
    super.key,
    this.data,
    this.initialAttendance,
    this.initialAttendanceLoadFailed = false,
  });
  final Program? data;
  final List<ProgramAttendance>? initialAttendance;
  final bool initialAttendanceLoadFailed;

  @override
  State<StudentsEnrollmentScreen> createState() =>
      _StudentsEnrollmentScreenState();
}

class _StudentsEnrollmentScreenState extends State<StudentsEnrollmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Api _api = Api();
  bool _isLoading = false;
  String _searchQuery = '';
  List<ProgramEnrollmentDetails> _enrollments = [];
  final Set<String> _selectedAdmissions = <String>{};
  bool _isSubmittingAttendance = false;
  bool _attendanceLoadFailed = false;
  List<ProgramAttendance> _attendance = [];
  bool _isAttendanceLoading = false;
  bool get _canSelectForAttendance {
    return _canMarkAttendance &&
        !_isAttendanceLoading &&
        !_attendanceLoadFailed;
  }

  bool get _isPastProgram =>
      widget.data?.date != null && !widget.data!.date!.isAfter(DateTime.now());

  bool get _canMarkAttendance {
    final role = LocalStorage().readUser().role;
    return role != 'vol' && _isPastProgram;
  }

  @override
  void initState() {
    super.initState();
    final c = Get.isRegistered<ProgramListController>()
        ? Get.find<ProgramListController>()
        : Get.put(ProgramListController());

    _enrollments = List.from(c.enrollmentList);
    if (_enrollments.isEmpty && widget.data?.id != null) {
      _fetchEnrollments();
    }

    if (widget.initialAttendance != null) {
      _attendance = List.from(widget.initialAttendance!);
      _isAttendanceLoading = false;
      _attendanceLoadFailed = widget.initialAttendanceLoadFailed;
    } else if (c.attendanceProgramId == widget.data?.id &&
        !c.isAttendanceLoading.value) {
      _attendance = List.from(c.programAttendanceList);
      _isAttendanceLoading = false;
      _attendanceLoadFailed = c.attendanceLoadFailed.value;
    } else if (_isPastProgram) {
      _fetchAttendance();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEnrollments() async {
    final programId = widget.data?.id;
    if (programId == null) return;

    setState(() => _isLoading = true);
    try {
      final res = await _api.getEnrolledStudents(programId);
      if (!mounted) return;
      if (res?.status == true && res?.enrollmentList != null) {
        setState(() {
          _enrollments = res!.enrollmentList!;
        });
        if (Get.isRegistered<ProgramListController>()) {
          Get.find<ProgramListController>().enrollmentList.assignAll(
            _enrollments,
          );
        }
      } else {
        CustomWidgets.showSnackBar(
          'Notice',
          res?.message ?? 'No enrolled volunteers found',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomWidgets.showSnackBar(
          'Error',
          'Failed to load enrolled volunteers: $e',
          backgroundColor: Colors.red.shade800,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchAttendance() async {
    final programId = widget.data?.id;
    if (programId == null) return;

    if (mounted) {
      setState(() {
        _isAttendanceLoading = true;
        _attendanceLoadFailed = false;
      });
    }

    try {
      final c = Get.isRegistered<ProgramListController>()
          ? Get.find<ProgramListController>()
          : Get.put(ProgramListController());
      final list = await c.fetchAttendanceForProgram(widget.data);

      if (!mounted) return;

      setState(() {
        _attendance = list;
        _attendanceLoadFailed = c.attendanceLoadFailed.value;
      });
    } catch (e) {
      log('Error fetching attendance in students enrollment screen: $e');

      if (!mounted) return;

      setState(() {
        _attendanceLoadFailed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAttendanceLoading = false;
        });
      }
    }
  }

  Future<void> _callVolunteer(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      CustomWidgets.showSnackBar(
        'Phone',
        'No phone number available',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }
    final sanitized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.length < 5) {
      CustomWidgets.showSnackBar(
        'Phone',
        'Invalid phone number',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }
    final uri = Uri.parse('tel:$sanitized');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomWidgets.showSnackBar(
          'Dialer',
          'Could not open phone dialer',
          backgroundColor: Colors.red.shade800,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } catch (_) {
      CustomWidgets.showSnackBar(
        'Dialer',
        'Could not open phone dialer',
        backgroundColor: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  void _viewVolunteer(String? admissionNo) {
    if (admissionNo == null || admissionNo.isEmpty) return;
    final volCtrl = Get.isRegistered<VolunteerListController>()
        ? Get.find<VolunteerListController>()
        : Get.put(VolunteerListController());
    volCtrl.viewVolunteerProfile(admissionNo);
  }

  void _showRecordAttendanceDialog() {
    final defaultHours = widget.data?.duration ?? 1;
    final TextEditingController hoursController = TextEditingController(
      text: defaultHours > 0 ? defaultHours.toString() : '1',
    );
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Record Attendance',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record attendance for ${_selectedAdmissions.length} selected volunteer(s) in "${widget.data?.name ?? 'Program'}".',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hours Served',
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 3',
                  filled: true,
                  fillColor: cs.outline.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isSubmittingAttendance
                  ? null
                  : () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _isSubmittingAttendance
                  ? null
                  : () async {
                      final hrs =
                          int.tryParse(hoursController.text.trim()) ?? 0;
                      if (hrs <= 0) {
                        CustomWidgets.showSnackBar(
                          'Invalid Hours',
                          'Please enter a valid positive number for hours.',
                          backgroundColor: Colors.red.shade800,
                          icon: const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                          ),
                        );
                        return;
                      }

                      final nav = Navigator.of(dialogCtx);
                      setDialogState(() => _isSubmittingAttendance = true);
                      setState(() => _isSubmittingAttendance = true);

                      final list = _selectedAdmissions
                          .map((admn) => {'volunteer': admn, 'hours': hrs})
                          .toList();

                      try {
                        final res = await _api.bulkAddAttendance(
                          widget.data!.id!,
                          list,
                        );
                        if (nav.canPop()) {
                          nav.pop();
                        }
                        if (res?.status ?? false) {
                          setState(() {
                            _selectedAdmissions.clear();
                          });
                          _fetchAttendance();
                          CustomWidgets.showSnackBar(
                            'Success',
                            res?.message ??
                                'Attendance marked successfully for volunteers',
                            backgroundColor: Colors.green.shade800,
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                          );
                        } else {
                          CustomWidgets.showSnackBar(
                            'Error',
                            res?.message ?? 'Failed to mark attendance',
                            backgroundColor: Colors.red.shade800,
                            icon: const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                          );
                        }
                      } catch (e) {
                        if (nav.canPop()) {
                          nav.pop();
                        }
                        CustomWidgets.showSnackBar(
                          'Error',
                          'Failed to mark attendance: $e',
                          backgroundColor: Colors.red.shade800,
                          icon: const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isSubmittingAttendance = false);
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmittingAttendance
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  ProgramAttendance? _getAttendance(ProgramEnrollmentDetails item) {
    final vol = item.volunteer;
    final admn1 = vol?.admissionNo?.trim().toLowerCase();
    final admn2 = item.volunteerAdmissionNo?.trim().toLowerCase();

    for (final att in _attendance) {
      final attVol = att.volunteer?.trim().toLowerCase();
      if (attVol == null || attVol.isEmpty || attVol == 'n/a') continue;
      if ((admn1 != null && admn1.isNotEmpty && attVol == admn1) ||
          (admn2 != null && admn2.isNotEmpty && attVol == admn2)) {
        return att;
      }
    }
    return null;
  }

  bool _hasAttendance(ProgramEnrollmentDetails item) {
    return _getAttendance(item) != null;
  }

  List<ProgramEnrollmentDetails> get _filteredEnrollments {
    if (_searchQuery.trim().isEmpty) {
      return _enrollments;
    }
    final q = _searchQuery.toLowerCase().trim();
    return _enrollments.where((item) {
      final vol = item.volunteer;
      final name = vol?.name?.toLowerCase() ?? '';
      final adm = (vol?.admissionNo ?? item.volunteerAdmissionNo ?? '')
          .toLowerCase();
      final dept = (vol?.department?.name ?? '').toLowerCase();
      final deptCat = (vol?.department?.category ?? '').toLowerCase();
      return name.contains(q) ||
          adm.contains(q) ||
          dept.contains(q) ||
          deptCat.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final program = widget.data;
    final filtered = _filteredEnrollments;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Enrolled Volunteers',
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Program Summary Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.onPrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.event_available_rounded,
                          color: cs.primary,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Program name
                            Text(
                              program?.name ?? 'Program Details',
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 5),

                            // Date + duration
                            Row(
                              children: [
                                if (program?.date != null) ...[
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: cs.onSurface.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat.yMMMd().format(program!.date!),
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurface.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],

                                if (program?.date != null &&
                                    program?.duration != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                    ),
                                    child: Container(
                                      width: 3,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: cs.onSurface.withOpacity(0.35),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),

                                if (program?.duration != null) ...[
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 14,
                                    color: cs.onSurface.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${program!.duration} hrs",
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurface.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Enrollment + attendance badges
                            Wrap(
                              spacing: 6,
                              runSpacing: 5,
                              children: [
                                // Enrolled
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer.withOpacity(
                                      0.65,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: cs.primary.withOpacity(0.18),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_alt_outlined,
                                        size: 14,
                                        color: cs.primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${_enrollments.length} Enrolled",
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Attendance
                                if (_isPastProgram && _enrollments.isNotEmpty)
                                  if (_isAttendanceLoading)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerHighest
                                            .withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: cs.outline.withOpacity(0.15),
                                        ),
                                      ),
                                      child: const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.6,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.09),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(0.20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 14,
                                            color: Colors.green.shade700,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${_enrollments.where(_hasAttendance).length}/${_enrollments.length} Attended",
                                            style: tt.labelSmall?.copyWith(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Search box
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: cs.outline.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Search enrolled volunteer or admission no...',
                        hintStyle: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: cs.onSurface.withOpacity(0.5),
                          size: 18,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: cs.onSurface.withOpacity(0.5),
                                  size: 16,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                        ),
                      ),
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                  ),
                ],
              ),
            ),

            // Optional Select All bar for attendance on past programs
            if (_canSelectForAttendance && filtered.isNotEmpty)
              Builder(
                builder: (context) {
                  final eligibleAdmissions = filtered
                      .where((item) {
                        final admn =
                            item.volunteer?.admissionNo ??
                            item.volunteerAdmissionNo;
                        return admn != null &&
                            admn.trim().isNotEmpty &&
                            admn != 'N/A' &&
                            !_hasAttendance(item);
                      })
                      .map(
                        (e) =>
                            (e.volunteer?.admissionNo ??
                                    e.volunteerAdmissionNo!)
                                .trim(),
                      )
                      .toSet();

                  final isAllSelected =
                      eligibleAdmissions.isNotEmpty &&
                      eligibleAdmissions.every(
                        (adm) => _selectedAdmissions.contains(adm),
                      );

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enrolled Volunteers (${filtered.length})',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        if (eligibleAdmissions.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                if (isAllSelected) {
                                  _selectedAdmissions.removeAll(
                                    eligibleAdmissions,
                                  );
                                } else {
                                  _selectedAdmissions.addAll(
                                    eligibleAdmissions,
                                  );
                                }
                              });
                            },
                            icon: Icon(
                              isAllSelected
                                  ? Icons.deselect_rounded
                                  : Icons.select_all_rounded,
                              size: 18,
                              color: cs.primary,
                            ),
                            label: Text(
                              isAllSelected ? 'Deselect All' : 'Select All',
                              style: tt.labelMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          _fetchEnrollments(),
                          _fetchAttendance(),
                        ]);
                      },
                      child: _enrollments.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.group_off_rounded,
                                          size: 64,
                                          color: cs.onSurface.withOpacity(0.2),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No volunteers enrolled',
                                          style: tt.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurface.withOpacity(
                                              0.6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Volunteers who self-enroll will appear here.',
                                          style: tt.bodySmall?.copyWith(
                                            color: cs.onSurface.withOpacity(
                                              0.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : filtered.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          size: 52,
                                          color: cs.onSurface.withOpacity(0.25),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No volunteers matching "$_searchQuery"',
                                          style: tt.titleSmall?.copyWith(
                                            color: cs.onSurface.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final vol = item.volunteer;
                                final admissionNo =
                                    vol?.admissionNo ??
                                    item.volunteerAdmissionNo ??
                                    'N/A';
                                final name = vol?.name ?? 'Volunteer';
                                final dept =
                                    "${vol?.department?.category ?? ''} ${vol?.department?.name ?? ''}"
                                        .trim();
                                final phone = vol?.phoneNumber;
                                final blood = vol?.bloodGroup;
                                final enrollmentDate = item.date;
                                final isSelected = _selectedAdmissions.contains(
                                  admissionNo,
                                );
                                final attendance = _getAttendance(item);
                                final attendanceAdded = attendance != null;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cs.primary.withOpacity(0.04)
                                        : cs.onPrimary,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? cs.primary
                                          : cs.outline.withOpacity(0.25),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.shadow.withOpacity(0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () {
                                        if (_canSelectForAttendance &&
                                            admissionNo != 'N/A' &&
                                            !attendanceAdded) {
                                          setState(() {
                                            if (_selectedAdmissions.contains(
                                              admissionNo,
                                            )) {
                                              _selectedAdmissions.remove(
                                                admissionNo,
                                              );
                                            } else {
                                              _selectedAdmissions.add(
                                                admissionNo,
                                              );
                                            }
                                          });
                                        } else {
                                          _viewVolunteer(
                                            vol?.admissionNo ??
                                                item.volunteerAdmissionNo,
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            if (_canSelectForAttendance &&
                                                admissionNo != 'N/A') ...[
                                              Checkbox(
                                                value: isSelected,
                                                activeColor: cs.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                onChanged: attendanceAdded
                                                    ? null
                                                    : (value) {
                                                        setState(() {
                                                          if (value == true) {
                                                            _selectedAdmissions
                                                                .add(
                                                                  admissionNo,
                                                                );
                                                          } else {
                                                            _selectedAdmissions
                                                                .remove(
                                                                  admissionNo,
                                                                );
                                                          }
                                                        });
                                                      },
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: cs.primary
                                                  .withOpacity(0.12),
                                              child: Text(
                                                name.isNotEmpty
                                                    ? name[0].toUpperCase()
                                                    : 'V',
                                                style: tt.titleMedium?.copyWith(
                                                  color: cs.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          name,
                                                          style: tt.titleSmall
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: cs
                                                                    .onSurface,
                                                              ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      if (blood != null &&
                                                          blood.isNotEmpty) ...[
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 1,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            blood,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "Adm No: $admissionNo${dept.isNotEmpty ? ' • $dept' : ''}",
                                                    style: tt.bodySmall
                                                        ?.copyWith(
                                                          color: cs.onSurface
                                                              .withOpacity(
                                                                0.65,
                                                              ),
                                                          fontSize: 11,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (enrollmentDate !=
                                                      null) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      "Enrolled: ${DateFormat.yMMMd().add_jm().format(enrollmentDate)}",
                                                      style: tt.bodySmall
                                                          ?.copyWith(
                                                            color: cs.onSurface
                                                                .withOpacity(
                                                                  0.45,
                                                                ),
                                                            fontSize: 10,
                                                          ),
                                                    ),
                                                  ],
                                                  if (_isPastProgram) ...[
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 9,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _isAttendanceLoading
                                                            ? cs.outline
                                                                  .withOpacity(
                                                                    0.08,
                                                                  )
                                                            : attendanceAdded
                                                            ? Colors
                                                                  .green
                                                                  .shade50
                                                            : Colors
                                                                  .orange
                                                                  .shade50,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              _isAttendanceLoading
                                                              ? cs.outline
                                                                    .withOpacity(
                                                                      0.2,
                                                                    )
                                                              : attendanceAdded
                                                              ? Colors
                                                                    .green
                                                                    .shade200
                                                              : Colors
                                                                    .orange
                                                                    .shade200,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (_isAttendanceLoading)
                                                            SizedBox(
                                                              width: 12,
                                                              height: 12,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth:
                                                                    1.5,
                                                                color: cs
                                                                    .onSurface
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                              ),
                                                            )
                                                          else
                                                            Icon(
                                                              attendanceAdded
                                                                  ? Icons
                                                                        .check_circle_rounded
                                                                  : Icons
                                                                        .access_time_rounded,
                                                              size: 13,
                                                              color:
                                                                  attendanceAdded
                                                                  ? Colors
                                                                        .green
                                                                        .shade700
                                                                  : Colors
                                                                        .orange
                                                                        .shade700,
                                                            ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            _isAttendanceLoading
                                                                ? 'Checking attendance...'
                                                                : attendanceAdded
                                                                ? '${(attendance.hours != null && attendance.hours! > 0) ? attendance.hours : (widget.data?.duration ?? 0)} hrs'
                                                                : "Not Added",
                                                            style: tt.bodySmall?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 11,
                                                              color:
                                                                  attendanceAdded
                                                                  ? Colors
                                                                        .green
                                                                        .shade700
                                                                  : Colors
                                                                        .orange
                                                                        .shade700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            if (phone != null &&
                                                phone.isNotEmpty)
                                              IconButton(
                                                tooltip: 'Call Volunteer',
                                                icon: Icon(
                                                  Icons.phone_outlined,
                                                  color: cs.primary,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _callVolunteer(phone),
                                              ),
                                            IconButton(
                                              tooltip: 'View Details',
                                              icon: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 14,
                                                color: cs.onSurface.withOpacity(
                                                  0.35,
                                                ),
                                              ),
                                              onPressed: () => _viewVolunteer(
                                                vol?.admissionNo ??
                                                    item.volunteerAdmissionNo,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          (_canMarkAttendance && _selectedAdmissions.isNotEmpty)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _isSubmittingAttendance
                        ? null
                        : _showRecordAttendanceDialog,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isSubmittingAttendance
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      'Record Attendance (${_selectedAdmissions.length})',
                      style: tt.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
