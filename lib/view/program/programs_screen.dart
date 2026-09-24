import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/common_pages/navbar.dart';
import 'package:nss_new/controller/program_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/view/program/add_program_screen.dart';
import 'package:nss_new/view/home_screen.dart';
import 'package:nss_new/model/programs_model.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late final ProgramListController c;
  late final AddProgramController addController;

  @override
  void initState() {
    super.initState();
    c = Get.isRegistered<ProgramListController>()
        ? Get.find<ProgramListController>()
        : Get.put(ProgramListController());
    addController = Get.isRegistered<AddProgramController>()
        ? Get.find<AddProgramController>()
        : Get.put(AddProgramController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      c.getPrograms();
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
      extendBody: true,
      backgroundColor: cs.surface,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      floatingActionButton: (role != 'vol')
          ? FloatingActionButton(
              onPressed: () {
                Get.to(
                  () => const AddProgramScreen(),
                )?.then((_) => c.getPrograms());
              },
              backgroundColor: cs.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed Top Navigation & Search Bar
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
                          hintText: 'Search programs...',
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

            // Fixed Title and Subtitle Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Programs',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover and participate in social service activities',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (role != 'vol') ...[
              Obx(() {
                final totalPrograms = c.programsList.length;
                final totalHours = c.programsList.fold<int>(
                  0,
                  (sum, p) => sum + (p.duration ?? 0),
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 9,
                          child: StatCard(
                            title: "Programs",
                            value: totalPrograms.toString(),
                            icon: Icons.event_rounded,
                            backgroundColor: cs.primary,
                            textColor: cs.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 11,
                          child: StatCard(
                            title: "Total Hours",
                            value: "$totalHours hrs",
                            icon: Icons.schedule_rounded,
                            backgroundColor: cs.secondary,
                            textColor: cs.onSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Fixed Tab Bar Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(
                    context,
                    'Upcoming Programs',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  _buildTabButton(
                    context,
                    'Past Activities',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Scrollable Program Cards Area
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                final filteredUpcoming = c.searchList.where((p) {
                  if (p.date == null) return false;
                  final pDate = DateTime(
                    p.date!.year,
                    p.date!.month,
                    p.date!.day,
                  );
                  final isUpcoming =
                      pDate.isAfter(today) || pDate.isAtSameMomentAs(today);

                  final titleMatch =
                      p.name?.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ??
                      false;
                  final descMatch =
                      p.description?.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ??
                      false;
                  return isUpcoming && (titleMatch || descMatch);
                }).toList();

                final filteredPast = c.searchList.where((p) {
                  if (p.date == null) return true;
                  final pDate = DateTime(
                    p.date!.year,
                    p.date!.month,
                    p.date!.day,
                  );
                  final isPast = pDate.isBefore(today);

                  final titleMatch =
                      p.name?.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ??
                      false;
                  final descMatch =
                      p.description?.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ??
                      false;
                  return isPast && (titleMatch || descMatch);
                }).toList();

                final currentList = _selectedTab == 0
                    ? filteredUpcoming
                    : filteredPast;

                return RefreshIndicator(
                  onRefresh: () async {
                    c.getPrograms();
                  },
                  child: currentList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.event_busy_outlined,
                                      size: 56,
                                      color: cs.onSurface.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'No programs matching "$_searchQuery"'
                                          : (_selectedTab == 0
                                                ? 'No upcoming programs scheduled'
                                                : 'No past activities found'),
                                      style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pull down to refresh',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 900
                                ? 3
                                : constraints.maxWidth > 600
                                ? 2
                                : 1;
                            return MasonryGridView.count(
                              crossAxisCount: crossAxisCount,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 90,
                              ),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              itemCount: currentList.length,
                              itemBuilder: (context, index) {
                                final program = currentList[index];

                                return _buildProgramCard(
                                  program: program,
                                  context: context,
                                  title: program.name ?? 'Untitled Program',
                                  date: program.date != null
                                      ? DateFormat.yMMMd().format(program.date!)
                                      : 'Date TBA',
                                  duration: '${program.duration ?? 0} hrs',
                                  description: program.description ?? '',
                                  isPast: _selectedTab == 1,
                                  cs: cs,
                                  tt: tt,
                                );
                              },
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

  Widget _buildTabButton(
    BuildContext context,
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                label,
                style: tt.titleSmall?.copyWith(
                  color: isSelected
                      ? cs.primary
                      : cs.onSurface.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: 2,
              color: isSelected ? cs.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  void _showEnrollConfirmationDialog(BuildContext context, Program program) {
    final cs = Theme.of(context).colorScheme;
    final programId = program.id;
    if (programId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Enrollment"),
        content: Text(
          "Are you sure you want to enroll in \"${program.name}\"?",
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
              Navigator.pop(context);
              c.enrollInProgram(programId);
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

  void _showCancelConfirmationDialog(BuildContext context, Program program) {
    final cs = Theme.of(context).colorScheme;
    final programId = program.id;
    if (programId == null) return;

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
              c.cancelEnrollment(programId);
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

  Widget _buildProgramCard({
    required BuildContext context,
    required Program program,
    required String title,
    required String date,
    required String duration,
    required String description,
    required bool isPast,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final role = LocalStorage().readUser().role;
    final Color cardBg = cs.onPrimary;
    final Color borderColor = cs.outline.withOpacity(0.6);
    final Color titleColor = cs.onSurface;
    final Color textColor = cs.onSurface.withOpacity(0.7);
    final Color iconColor = cs.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  date,
                  style: tt.bodySmall?.copyWith(color: textColor),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.hourglass_empty, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(duration, style: tt.bodySmall?.copyWith(color: textColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: tt.bodyMedium?.copyWith(color: textColor, height: 1.4),
          ),
          if (!isPast) ...[
            const SizedBox(height: 16),
            if (role == 'vol')
              Obx(() {
                final programId = program.id;
                if (programId == null) return const SizedBox.shrink();

                final isChecking =
                    c.isCheckingEnrollment.value ||
                    !c.verifiedProgramEnrollmentIds.contains(programId);
                final isEnrolled = c.isEnrolled(programId);
                final isEnrolling = c.enrollingProgramIds.contains(programId);
                final isCancelling = c.cancellingProgramIds.contains(programId);
                final canCancel = c.canCancelEnrollment(programId);
                final remainingText = c.getRemainingCancellationText(programId);

                // 1. Initial / Loading state: NEVER show "Enroll Now" until status is verified
                if (isChecking) {
                  return SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: FilledButton.tonal(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 2. Volunteer is NOT enrolled
                if (!isEnrolled) {
                  final isPastProgram =
                      isPast ||
                      (program.date != null &&
                          program.date!.isBefore(DateTime.now()));
                  final isLimitReached =
                      program.limit != null &&
                      program.limit! > 0 &&
                      (program.enrollmentCount ?? 0) >= program.limit!;
                  final isEnrollmentAllowed = !isPastProgram && !isLimitReached;
                  final buttonLabel = isLimitReached
                      ? 'Program Full'
                      : 'Enroll Now';

                  return SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: FilledButton(
                      onPressed:
                          (!isEnrollmentAllowed || isEnrolling || isCancelling)
                          ? null
                          : () {
                              _showEnrollConfirmationDialog(context, program);
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.secondary,
                        foregroundColor: cs.onSecondary,
                        disabledBackgroundColor: cs.secondary.withOpacity(0.6),
                        disabledForegroundColor: cs.onSecondary.withOpacity(
                          0.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: isEnrolling
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Enrolling...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              buttonLabel,
                              style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSecondary,
                              ),
                            ),
                    ),
                  );
                } else if (canCancel) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: (isEnrolling || isCancelling)
                              ? null
                              : () {
                                  _showCancelConfirmationDialog(
                                    context,
                                    program,
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                            side: BorderSide(color: cs.error.withOpacity(0.7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isCancelling
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.error,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cancel_outlined, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Cancel Enrollment',
                                      style: tt.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: cs.error,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            remainingText,
                            style: tt.bodySmall?.copyWith(
                              fontSize: 11,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: FilledButton.icon(
                          onPressed: null,
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                          ),
                          label: const Text('Enrollment Confirmed'),
                          style: FilledButton.styleFrom(
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cancellation period expired (24h limit)',
                        textAlign: TextAlign.center,
                        style: tt.bodySmall?.copyWith(
                          fontSize: 11,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  );
                }
              }),
            if (role != 'vol') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(
                        () => AddProgramScreen(program: program),
                      )?.then((_) => c.getPrograms()),
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text("Edit", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Obx(() {
                      final isLoading = c.loadingEnrollmentProgramIds.contains(
                        program.id,
                      );
                      return ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                c.getEnrolledStudents(program);
                              },
                        icon: isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.indigo,
                                ),
                              )
                            : const Icon(Icons.people_rounded, size: 14),
                        label: Text(
                          isLoading ? "Loading" : "Volunteers",
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primaryContainer,
                          foregroundColor: cs.onPrimaryContainer,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      final addController = Get.find<AddProgramController>();

                      addController.isDeleteButtonLoading.value = false;
                      CustomWidgets().showConfirmationDialog(
                        title: "Delete Program",
                        message:
                            "Are you sure you want to delete this program?",
                        onConfirm: () async {
                          await addController.deleteProgram(program.id!);
                        },
                        data: Obx(
                          () => addController.isDeleteButtonLoading.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Confirm",
                                  style: TextStyle(color: Colors.red),
                                ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: cs.error,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.errorContainer.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (isPast && role != 'vol') ...[
            const SizedBox(height: 16),
            Obx(() {
              final isLoading = c.loadingEnrollmentProgramIds.contains(
                program.id,
              );
              return ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        c.getEnrolledStudents(program);
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.indigo,
                        ),
                      )
                    : const Icon(Icons.people_rounded, size: 14),
                label: Text(
                  isLoading ? "Loading" : "Volunteers",
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
