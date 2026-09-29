import 'package:nss_new/view/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/common_pages/navbar.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/view/program/add_program_screen.dart';
import 'package:nss_new/view/attendance/manage_attendance_screen.dart';
import 'package:nss_new/view/manage_blood_requirement_screen.dart';
import 'package:nss_new/view/volunteer/manage_volunteer_screen.dart';
import 'package:nss_new/view/program/programs_screen.dart';
import 'package:nss_new/controller/blood_requirement_controller.dart';
import 'package:nss_new/controller/home_controller.dart';
import 'package:nss_new/controller/attendance_controller.dart';
import 'package:nss_new/model/programs_model.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/view/blood_requirement_details_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final BloodRequirementController bloodController;
  late final HomeController homeController;
  AttendanceController? attendanceController;

  @override
  void initState() {
    super.initState();
    bloodController = Get.isRegistered<BloodRequirementController>()
        ? Get.find<BloodRequirementController>()
        : Get.put(BloodRequirementController());
    homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    final user = LocalStorage().readUser();
    if (user.role == 'vol') {
      attendanceController = Get.isRegistered<AttendanceController>()
          ? Get.find<AttendanceController>()
          : Get.put(AttendanceController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      homeController.refreshDashboard();
      bloodController.fetchBloodRequests();
      if (attendanceController != null &&
          user.admissionNo != null &&
          user.admissionNo!.isNotEmpty) {
        attendanceController!.getAttendance(user.admissionNo!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = LocalStorage().readUser();
    final isVolunteer = user.role == 'vol';

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xffF8F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  homeController.refreshDashboard();
                  bloodController.fetchBloodRequests();
                  if (isVolunteer) {
                    attendanceController?.getAttendance(user.admissionNo ?? '');
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      /// HEADER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff26206B), Color(0xff5A52B3)],
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "INSTITUTIONAL CHAPTER",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.white70,
                                              letterSpacing: 1,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "NSS Farook College",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 25),
                                      Text(
                                        "Hello, ${LocalStorage().readUser().name}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: Colors.white),
                                      ),

                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),

                                Column(
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 8,
                                            color: Colors.black12,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/logos/logo.png',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Obx(() {
                                      final count =
                                          homeController
                                              .openBloodRequests
                                              .length +
                                          homeController
                                              .upcomingPrograms
                                              .length;
                                      return Material(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          onTap: () => Get.to(
                                            () => const NotificationsScreen(),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .notifications_outlined,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    if (count > 0)
                                                      Positioned(
                                                        top: -3,
                                                        right: -3,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                2,
                                                              ),
                                                          decoration:
                                                              const BoxDecoration(
                                                                color: Colors
                                                                    .redAccent,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                          constraints:
                                                              const BoxConstraints(
                                                                minWidth: 12,
                                                                minHeight: 12,
                                                              ),
                                                          child: Text(
                                                            '$count',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 8,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'Alerts',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -25),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildStatsCard(context, attendanceController),
                        ),
                      ),
                      if (LocalStorage().readUser().role != 'vol') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _actionCard(
                                  context,
                                  icon: Icons.star,
                                  bg: Colors.red.shade100,
                                  iconColor: Colors.red,
                                  title: "Manage Attendance",
                                  onTap: () => Get.to(
                                    () => const ManageAttendanceScreen(),
                                  ),
                                ),
                                _actionCard(
                                  context,

                                  icon: Icons.description_outlined,
                                  bg: Colors.amber.shade100,
                                  iconColor: Colors.orange,
                                  title: "Add Program",
                                  onTap: () =>
                                      Get.to(() => const AddProgramScreen()),
                                ),
                                _actionCard(
                                  context,

                                  icon: Icons.menu_book_outlined,
                                  bg: Colors.indigo.shade100,
                                  iconColor: Colors.indigo,
                                  title: "Manage Volunteer",
                                  onTap: () => Get.to(
                                    () => const ManageVolunteerScreen(),
                                  ),
                                ),
                                _actionCard(
                                  context,

                                  icon: Icons.bloodtype_outlined,
                                  bg: Colors.red.shade100,
                                  iconColor: Colors.red,
                                  title: "Blood Requirement",
                                  onTap: () => Get.to(
                                    () => const ManageBloodRequirementScreen(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      Obx(() {
                        final bloodAlerts = homeController.openBloodRequests;
                        final programAlerts = homeController.upcomingPrograms;
                        final totalAlerts =
                            bloodAlerts.length + programAlerts.length;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Latest Notifications',
                                        style: tt.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: cs.primary,
                                        ),
                                      ),
                                      if (totalAlerts > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade700,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            totalAlerts.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () => Get.to(
                                      () => const NotificationsScreen(),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'View All',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: cs.primary,
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
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (totalAlerts == 0)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.onPrimary,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: cs.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'All caught up! No emergency alerts today.',
                                          style: tt.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (bloodAlerts.isNotEmpty) ...[
                                Builder(
                                  builder: (context) {
                                    final req = bloodAlerts.first;
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => Get.to(
                                          () => const NotificationsScreen(),
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50
                                                .withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: Colors.red.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade700,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  req.bloodGroup ?? 'Alert',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'URGENT BLOOD REQUIREMENT',
                                                      style: TextStyle(
                                                        color:
                                                            Colors.red.shade900,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11,
                                                        letterSpacing: 0.4,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${req.patientName ?? "Patient"} • ${req.hospital ?? "Hospital"}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: tt.bodySmall
                                                          ?.copyWith(
                                                            color: Colors
                                                                .red
                                                                .shade900,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 13,
                                                color: Colors.red.shade700,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ] else ...[
                                Builder(
                                  builder: (context) {
                                    final prog = programAlerts.first;
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => Get.to(
                                          () => const NotificationsScreen(),
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: cs.onPrimary,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: cs.outline.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: cs.primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.campaign,
                                                  size: 18,
                                                  color: cs.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      prog.name ??
                                                          'New Program Announcement',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: tt.bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    if (prog.date != null)
                                                      Text(
                                                        DateFormat.MMMd()
                                                            .format(prog.date!),
                                                        style: tt.bodySmall
                                                            ?.copyWith(
                                                              color: cs
                                                                  .onSurfaceVariant,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 13,
                                                color: cs.primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Upcoming Programs",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(color: cs.primary),
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => const ProgramsScreen());
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffECE6FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "View All",
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .copyWith(color: cs.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      Obx(() {
                        if (homeController.isLoading.value) {
                          return const SizedBox(
                            height: 280,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (homeController.upcomingPrograms.isEmpty) {
                          return SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                "No upcoming programs found",
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: isVolunteer ? 220 : 190,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            itemCount: homeController.upcomingPrograms.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final program =
                                  homeController.upcomingPrograms[index];
                              return _programCard(
                                context,
                                cs,
                                program,
                                homeController,
                              );
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Active Blood Requirements",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(color: cs.primary),
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(
                                  () => const ManageBloodRequirementScreen(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffECE6FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "View All",
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .copyWith(color: cs.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Obx(() {
                        if (bloodController.isLoading.value) {
                          return const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final activeReqs = bloodController.requirements.where((
                          req,
                        ) {
                          final status = (req.status ?? 'open')
                              .trim()
                              .toLowerCase();
                          if (status.contains('complete') ||
                              status.contains('cancel') ||
                              status.contains('fulfill') ||
                              status.contains('close') ||
                              status.contains('resolve')) {
                            return false;
                          }
                          return status == 'open' ||
                              status == 'pending' ||
                              status == 'active' ||
                              status.isEmpty;
                        }).toList();

                        if (activeReqs.isEmpty) {
                          return SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                "No active blood requirements",
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 280,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            itemCount: activeReqs.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final req = activeReqs[index];
                              return _bloodRequirementCard(context, cs, req);
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xffF2EFF5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "\"The best way to find yourself is\n"
                                "to lose yourself in the service of\n"
                                "others.\"",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge!
                                    .copyWith(
                                      color: cs.primary,
                                      fontStyle: FontStyle.italic,
                                      height: 1.5,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "— Mahatma Gandhi",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required Color bg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 105,
          height: 96,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: bg,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    AttendanceController? attendanceController,
  ) {
    final cs = Theme.of(context).colorScheme;
    final user = LocalStorage().readUser();
    final isVolunteer = user.role == 'vol';

    if (!isVolunteer || attendanceController == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: cs.primary.withOpacity(0.1),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: cs.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.role == 'sec'
                        ? "Secretary Dashboard"
                        : "Officer Dashboard",
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Manage volunteers, attendance, blood requests and programs.",
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      final totalP = attendanceController.totalPrograms.value;
      final isL = attendanceController.isAttendanceLoading.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: totalP > 0 ? (totalP / 30).clamp(0.0, 1.0) : 0.0,
                      strokeWidth: 7,
                      backgroundColor: Colors.grey.shade200,
                      color: cs.primary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isL ? "..." : "$totalP",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ATTENDED",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.primary.withOpacity(.8),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Great Work!",
                    style: TextStyle(
                      color: Color(0xff5A52B3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("You've completed $totalP programs."),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

void _showEnrollConfirmationDialog(
  BuildContext context,
  Program program,
  HomeController homeController,
) {
  final cs = Theme.of(context).colorScheme;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Confirm Enrollment"),
      content: Text("Are you sure you want to enroll in \"${program.name}\"?"),
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
            Navigator.pop(context);
            homeController.enroll(program);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _showCancelConfirmationDialog(
  BuildContext context,
  Program program,
  HomeController homeController,
) {
  final cs = Theme.of(context).colorScheme;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Cancel Enrollment"),
      content: Text(
        "Are you sure you want to cancel your enrollment in \"${program.name}\"?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Keep Enrollment",
            style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            homeController.cancelEnrollment(program);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Confirm Cancel",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

Widget _programCard(
  BuildContext context,
  ColorScheme cs,
  Program program,
  HomeController homeController,
) {
  final tt = Theme.of(context).textTheme;

  final dateStr = program.date != null
      ? DateFormat.yMMMd().format(program.date!)
      : 'N/A';

  final user = LocalStorage().readUser();
  final isVolunteer = user.role == 'vol';

  return Container(
    width: 240,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─────────────────────────────────────────────
        // TITLE
        // ─────────────────────────────────────────────
        Text(
          program.name ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: tt.titleMedium?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),

        const SizedBox(height: 10),

        // ─────────────────────────────────────────────
        // DESCRIPTION
        // ─────────────────────────────────────────────
        Text(
          program.description ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.70),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 14),

        // ─────────────────────────────────────────────
        // PROGRAM META
        // ─────────────────────────────────────────────
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: cs.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  dateStr,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.70),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_outlined, size: 15, color: cs.primary),
                const SizedBox(width: 5),
                Text(
                  '${program.duration ?? 0} hrs',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.70),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Enrolled / limit for PO & Secretary
            if (!isVolunteer)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 15,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    program.limit != null && program.limit! > 0
                        ? '${program.enrollmentCount ?? 0} / ${program.limit}'
                        : '${program.enrollmentCount ?? 0}',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.70),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'enrolled',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.60),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        // ─────────────────────────────────────────────
        // VOLUNTEER ENROLLMENT / ACTION
        // ─────────────────────────────────────────────
        if (isVolunteer) ...[
          const SizedBox(height: 14),

          Divider(height: 1, color: cs.outline.withOpacity(0.15)),

          const SizedBox(height: 12),

          Obx(() {
            final programId = program.id;

            if (programId == null) {
              return const SizedBox.shrink();
            }

            final isChecking =
                homeController.isCheckingEnrollment.value ||
                !homeController.verifiedProgramEnrollmentIds.contains(
                  programId,
                );

            final isEnrolled = homeController.isEnrolled(programId);

            final isEnrolling = homeController.enrollingProgramIds.contains(
              programId,
            );

            final isCancelling = homeController.cancellingProgramIds.contains(
              programId,
            );

            final canCancel = homeController.canCancelEnrollment(programId);

            final remainingText = homeController.getRemainingCancellationText(
              programId,
            );

            // ─────────────────────────────────────
            // CHECKING ENROLLMENT
            // ─────────────────────────────────────
            if (isChecking) {
              return SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Checking enrollment...',
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ─────────────────────────────────────
            // NOT ENROLLED
            // ─────────────────────────────────────
            if (!isEnrolled) {
              final isLimitReached =
                  program.limit != null &&
                  program.limit! > 0 &&
                  (program.enrollmentCount ?? 0) >= program.limit!;

              final buttonLabel = isLimitReached
                  ? 'Program Full'
                  : 'Enroll Now';

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLimitReached
                        ? cs.outline.withOpacity(0.25)
                        : cs.primary,
                    foregroundColor: isLimitReached
                        ? cs.onSurface.withOpacity(0.5)
                        : Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (isEnrolling || isCancelling)
                      ? null
                      : isLimitReached
                      ? () {
                          CustomWidgets.showSnackBar(
                            'Limit Exceeded',
                            'Limit exceeded. Cannot enroll in this program.',
                            backgroundColor: Colors.red.shade800,
                            icon: const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                          );
                        }
                      : () {
                          _showEnrollConfirmationDialog(
                            context,
                            program,
                            homeController,
                          );
                        },
                  child: isEnrolling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              );
            }

            // ─────────────────────────────────────
            // ENROLLED + CANCELLATION AVAILABLE
            // ─────────────────────────────────────
            if (canCancel) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(color: cs.error.withOpacity(0.6)),
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (isEnrolling || isCancelling)
                          ? null
                          : () {
                              _showCancelConfirmationDialog(
                                context,
                                program,
                                homeController,
                              );
                            },
                      child: isCancelling
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.error,
                              ),
                            )
                          : const Text(
                              'Cancel Enrollment',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 13,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          remainingText,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // ─────────────────────────────────────
            // ENROLLED + CANCELLATION EXPIRED
            // ─────────────────────────────────────
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 17,
                    ),
                    label: const Text('Enrolled'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Cancellation expired (24h limit)',
                  textAlign: TextAlign.center,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            );
          }),
        ],
      ],
    ),
  );
}

Widget _bloodRequirementCard(
  BuildContext context,
  ColorScheme cs,
  BloodDonationRequest req,
) {
  final tt = Theme.of(context).textTheme;
  final bloodGroup = req.bloodGroup?.isNotEmpty == true
      ? req.bloodGroup!
      : 'Any';
  final patientName = req.patientName?.isNotEmpty == true
      ? req.patientName!
      : 'Patient in need';
  final units =
      '${req.unitsRequired ?? 1} Unit${(req.unitsRequired ?? 1) > 1 ? 's' : ''}';
  final hospital = req.hospital?.isNotEmpty == true
      ? req.hospital!
      : 'Hospital not specified';
  final contactPerson = req.contactPerson?.isNotEmpty == true
      ? req.contactPerson!
      : 'NSS Coordinator';
  final contactNumber = req.contactNumber?.isNotEmpty == true
      ? req.contactNumber!
      : '';
  final neededDate = req.neededBefore?.isNotEmpty == true
      ? req.neededBefore!
      : 'ASAP';
  final urgency = (req.urgency ?? 'Normal').toUpperCase();
  final status = (req.status ?? 'Open').toUpperCase();

  final hasValidPhone =
      contactNumber.replaceAll(RegExp(r'[^0-9+]'), '').length >= 5;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => BloodRequirementDetailsSheet.show(context, req),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.secondary.withOpacity(0.12),
                  child: Text(
                    bloodGroup,
                    style: TextStyle(
                      color: cs.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: urgency.contains('CRITIC')
                        ? cs.error.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    urgency,
                    style: TextStyle(
                      color: urgency.contains('CRITIC')
                          ? cs.error
                          : Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                if (hasValidPhone)
                  IconButton.filledTonal(
                    icon: const Icon(Icons.phone, size: 16),
                    tooltip: 'Call $contactPerson',
                    onPressed: () => BloodRequirementDetailsSheet.makeCall(
                      context,
                      contactNumber,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green.shade800,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              patientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleMedium!.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  size: 18,
                  color: cs.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hospital,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.water_drop_outlined, size: 18, color: cs.secondary),
                const SizedBox(width: 8),
                Text(
                  units,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: cs.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Needed: $neededDate',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () =>
                    BloodRequirementDetailsSheet.show(context, req),
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
