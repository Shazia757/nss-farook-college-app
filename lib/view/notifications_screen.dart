import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/controller/home_controller.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/view/blood_requirement_details_sheet.dart';
import 'package:nss_new/view/program/programs_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final HomeController homeController;
  int _selectedFilterIndex = 0; // 0: All, 1: Alerts, 2: Announcements

  @override
  void initState() {
    super.initState();
    homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      homeController.refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xffF8F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outline.withValues(alpha: 0.2)),
        ),
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final bloodAlerts = homeController.openBloodRequests;
        final programAnnouncements = homeController.upcomingPrograms;

        final totalAlerts = bloodAlerts.length;
        final totalAnnouncements = programAnnouncements.length;
        final totalAll = totalAlerts + totalAnnouncements;

        return Column(
          children: [
            // Filter Chips Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterChip(
                      context,
                      label: 'All',
                      count: totalAll,
                      index: 0,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: 'Alerts',
                      count: totalAlerts,
                      index: 1,
                      badgeColor: Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: 'Announcements',
                      count: totalAnnouncements,
                      index: 2,
                      badgeColor: cs.primary,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Content List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  homeController.refreshDashboard();
                },
                child: _buildListContent(
                  context,
                  bloodAlerts: bloodAlerts,
                  programAnnouncements: programAnnouncements,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required int count,
    required int index,
    Color? badgeColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedFilterIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : cs.onSurface,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (badgeColor ?? cs.primary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (badgeColor ?? cs.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context, {
    required List<BloodDonationRequest> bloodAlerts,
    required List<Program> programAnnouncements,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final showAlerts = _selectedFilterIndex == 0 || _selectedFilterIndex == 1;
    final showAnnouncements =
        _selectedFilterIndex == 0 || _selectedFilterIndex == 2;

    final hasItems =
        (showAlerts && bloodAlerts.isNotEmpty) ||
        (showAnnouncements && programAnnouncements.isNotEmpty);

    if (!hasItems) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: cs.primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "All Caught Up!",
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedFilterIndex == 1
                      ? "No active blood donation alerts at this time."
                      : _selectedFilterIndex == 2
                      ? "No upcoming program announcements currently."
                      : "No new notifications or emergency alerts today.",
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => homeController.refreshDashboard(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("Check Again"),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      children: [
        if (showAlerts && bloodAlerts.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: "Emergency Blood Alerts",
            count: bloodAlerts.length,
            icon: Icons.bloodtype,
            color: cs.primary,
          ),
          const SizedBox(height: 10),
          ...bloodAlerts.map((req) => _buildAlertCard(context, req)),
          const SizedBox(height: 16),
        ],
        if (showAnnouncements && programAnnouncements.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: "Program Announcements",
            count: programAnnouncements.length,
            icon: Icons.campaign_rounded,
            color: cs.primary,
          ),
          const SizedBox(height: 10),
          ...programAnnouncements.map(
            (prog) => _buildAnnouncementCard(context, prog),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, BloodDonationRequest req) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final bloodGroup = (req.bloodGroup?.isNotEmpty ?? false)
        ? req.bloodGroup!
        : 'Any';
    final patientName = (req.patientName?.isNotEmpty ?? false)
        ? req.patientName!
        : 'Patient in need';
    final units =
        '${req.unitsRequired ?? 1} Unit${(req.unitsRequired ?? 1) > 1 ? 's' : ''}';
    final hospital = (req.hospital?.isNotEmpty ?? false)
        ? req.hospital!
        : 'Hospital not specified';
    final contactPerson = (req.contactPerson?.isNotEmpty ?? false)
        ? req.contactPerson!
        : 'NSS Coordinator';

    final neededDate = (req.neededBefore?.isNotEmpty ?? false)
        ? req.neededBefore!
        : 'ASAP';
    final urgency = (req.urgency ?? 'Normal').toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => BloodRequirementDetailsSheet.show(context, req),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Row: Blood Group, Type Badge, Urgency, Status, Call Button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bloodtype,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bloodGroup,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: const Text(
                        "EMERGENCY ALERT",
                        style: TextStyle(
                          color: Color(0xFFB71C1C),
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: urgency.contains('CRITIC')
                            ? Colors.red.shade200
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        urgency,
                        style: TextStyle(
                          color: urgency.contains('CRITIC')
                              ? Colors.red.shade900
                              : Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Patient and units
                Text(
                  'Patient: $patientName ($units)',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 4),

                // Hospital
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 15,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        hospital,
                        style: tt.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Date Needed & Contact
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 15, color: cs.primary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Needed before: $neededDate • Contact: $contactPerson',
                        style: tt.bodySmall?.copyWith(color: cs.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Bottom hint row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tap to view requirement details',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: cs.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, Program prog) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => const ProgramsScreen());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge & Event Date Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.campaign, size: 13, color: cs.primary),
                          const SizedBox(width: 4),
                          Text(
                            "ANNOUNCEMENT",
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (prog.date != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(prog.date!),
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Program Title
                Text(
                  prog.name ?? 'Upcoming NSS Event',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                if (prog.description != null &&
                    prog.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    prog.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                // Meta Row: Duration & View Action
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${prog.duration ?? 0} Hours',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (prog.limit != null && prog.limit! > 0) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.group_outlined,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Limit: ${prog.enrollmentCount ?? 0}/${prog.limit}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      'View Program',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: cs.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
