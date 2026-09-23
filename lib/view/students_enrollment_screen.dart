import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/program_controller.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/model/enrollment_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentsEnrollmentScreen extends StatefulWidget {
  const StudentsEnrollmentScreen({super.key, this.data});
  final Program? data;

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
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _callVolunteer(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      CustomWidgets.showSnackBar('Phone', 'No phone number available');
      return;
    }
    final sanitized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.length < 5) {
      CustomWidgets.showSnackBar('Phone', 'Invalid phone number');
      return;
    }
    final uri = Uri.parse('tel:$sanitized');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomWidgets.showSnackBar('Dialer', 'Could not open phone dialer');
      }
    } catch (_) {
      CustomWidgets.showSnackBar('Dialer', 'Could not open phone dialer');
    }
  }

  void _viewVolunteer(String? admissionNo) {
    if (admissionNo == null || admissionNo.isEmpty) return;
    final volCtrl = Get.isRegistered<VolunteerListController>()
        ? Get.find<VolunteerListController>()
        : Get.put(VolunteerListController());
    volCtrl.viewVolunteerProfile(admissionNo);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enrolled Volunteers',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            if (program?.name != null)
              Text(
                program!.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh List',
            icon: Icon(Icons.refresh, color: cs.primary),
            onPressed: _isLoading ? null : _fetchEnrollments,
          ),
        ],
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
                            Text(
                              program?.name ?? 'Program Details',
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
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
                                  const SizedBox(width: 12),
                                ],
                                if (program?.duration != null) ...[
                                  Icon(
                                    Icons.schedule,
                                    size: 13,
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
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cs.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          "${_enrollments.length} Enrolled",
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
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

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchEnrollments,
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

                                return Container(
                                  decoration: BoxDecoration(
                                    color: cs.onPrimary,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: cs.outline.withOpacity(0.25),
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
                                      onTap: () => _viewVolunteer(
                                        vol?.admissionNo ??
                                            item.volunteerAdmissionNo,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
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
    );
  }
}
