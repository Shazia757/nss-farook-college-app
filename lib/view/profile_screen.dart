import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/navbar.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/view/add_volunteer_screen.dart';
import 'package:nss_new/view/authentication/login_screen.dart';
import 'package:nss_new/view/authentication/change_password_screen.dart';
import 'package:nss_new/view/authentication/delete_account_screen.dart';
import 'package:nss_new/view/view_attendance_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Users? volunteer;
  final Rxn<Users> rxVolunteer = Rxn<Users>();

  ProfileScreen({super.key, this.volunteer}) {
    rxVolunteer.value = volunteer ?? LocalStorage().readUser();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final role = LocalStorage().readUser().role;

    final isOwnProfile = volunteer == null;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: isOwnProfile
          ? CustomBottomNavBar(currentIndex: role == 'po' ? 3 : 4)
          : null,
      appBar: !isOwnProfile
          ? AppBar(
              backgroundColor: cs.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: cs.primary),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Volunteer Profile',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Obx(() {
          final displayVol = rxVolunteer.value;
          final name = displayVol?.name;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                children: [
                  /// ── PROFILE HERO CARD ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.primary.withOpacity(0.78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 42,
                                  backgroundColor: Colors.white.withOpacity(.2),
                                  child: Text(
                                    (name != null && name.isNotEmpty)
                                        ? name.substring(0, 1).toUpperCase()
                                        : "S",
                                    style: tt.headlineLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(
                                displayVol?.name ?? "NSS User",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                              ),

                              const SizedBox(height: 4),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  displayVol?.role == 'sec'
                                      ? "Secretary"
                                      : displayVol?.role == 'po'
                                      ? "Program Officer"
                                      : "Volunteer",
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        letterSpacing: 0.3,
                                      ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  if (isOwnProfile)
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => Get.to(
                                          () => ChangePasswordScreen(
                                            userId:
                                                displayVol?.admissionNo ?? '',
                                            isChangepassword: true,
                                          ),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.white
                                              .withOpacity(0.18),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.lock_reset_rounded,
                                        ),
                                        label: const Text("Change Password"),
                                      ),
                                    ),
                                  if (!isOwnProfile && displayVol != null) ...[
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: FilledButton.icon(
                                              onPressed: () => Get.to(
                                                () => ChangePasswordScreen(
                                                  userId:
                                                      displayVol.admissionNo ??
                                                      '',
                                                  isChangepassword: false,
                                                ),
                                              ),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.white
                                                    .withOpacity(0.18),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.lock_reset_rounded,
                                              ),
                                              label: const Text(
                                                "Reset Password",
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: double.infinity,
                                            child: FilledButton.icon(
                                              onPressed: () {
                                                Get.to(
                                                  () => AddVolunteerScreen(
                                                    volunteer: displayVol,
                                                  ),
                                                )?.then((_) {
                                                  if (displayVol.admissionNo !=
                                                      null) {
                                                    Api()
                                                        .volunteerDetails(
                                                          displayVol
                                                              .admissionNo!,
                                                        )
                                                        .then((val) {
                                                          if (val?.volunteerDetails !=
                                                              null) {
                                                            rxVolunteer
                                                                .value = val!
                                                                .volunteerDetails;
                                                          }
                                                        });
                                                  }
                                                  if (Get.isRegistered<
                                                    VolunteerListController
                                                  >()) {
                                                    Get.find<
                                                          VolunteerListController
                                                        >()
                                                        .getData();
                                                  }
                                                });
                                              },
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: cs.primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.edit_rounded,
                                              ),
                                              label: const Text("Edit Profile"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= PERSONAL DETAILS =================
                  _SectionCard(
                    title: "Personal Details",
                    icon: Icons.person_outline_rounded,
                    child: Column(
                      children: [
                        _InfoRow(
                          label: "Gender",
                          value: displayVol?.gender ?? "N/A",
                          icon: Icons.wc_rounded,
                        ),
                        const _Divider(),

                        _InfoRow(
                          label: "Date of Birth",
                          value: displayVol?.dob != null
                              ? DateFormat.yMMMd().format(displayVol!.dob!)
                              : "N/A",
                          icon: Icons.cake_outlined,
                        ),
                        const _Divider(),

                        _InfoRow(
                          label: "Caste",
                          value: displayVol?.caste ?? "N/A",
                          icon: Icons.groups_outlined,
                        ),
                        const _Divider(),

                        _InfoRow(
                          label: "Blood Group",
                          value: displayVol?.bloodGroup ?? "N/A",
                          icon: Icons.bloodtype_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= ACADEMIC DETAILS =================
                  if (role != 'po')
                    _SectionCard(
                      title: "Academic Details",
                      icon: Icons.school_outlined,
                      child: Column(
                        children: [
                          _InfoRow(
                            label: "Programme",
                            value: displayVol?.department != null
                                ? "${displayVol?.department?.category ?? ''} ${displayVol?.department?.name ?? ''}"
                                : "N/A",
                            icon: Icons.menu_book_outlined,
                          ),
                          const _Divider(),

                          _InfoRow(
                            label: "Year of Study",
                            value: displayVol?.year ?? "N/A",
                            icon: Icons.calendar_today_outlined,
                          ),
                          const _Divider(),

                          _InfoRow(
                            label: "Admission No.",
                            value: displayVol?.admissionNo ?? "N/A",
                            icon: Icons.badge_outlined,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ================= CONTACT DETAILS =================
                  _SectionCard(
                    title: "Contact Info",
                    icon: Icons.contact_phone_outlined,
                    child: Column(
                      children: [
                        _InfoRow(
                          label: "Email",
                          value: displayVol?.email ?? "N/A",
                          icon: Icons.mail_outline_rounded,
                        ),
                        const _Divider(),

                        _InfoRow(
                          label: "Phone Number",
                          value: displayVol?.phoneNo ?? "N/A",
                          icon: Icons.phone_outlined,
                        ),
                      ],
                    ),
                  ),

                  // ================= ATTENDANCE HISTORY FOR SEC/PO =================
                  if (displayVol != null && displayVol.role == 'vol') ...[
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: "Participation & Attendance",
                      icon: Icons.assignment_turned_in_outlined,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(
                              () => AttendanceScreen(volunteer: displayVol),
                            );
                          },
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text("View Attendance History"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primaryContainer,
                            foregroundColor: cs.onPrimaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  /// ── DANGER ZONE (LOGOUT & DELETION) ──────────────────────────────
                  if (isOwnProfile) _DangerZoneCard(cs: cs),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  child: Icon(icon, size: 18, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.primary.withOpacity(0.7)),
          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  final ColorScheme cs;

  const _DangerZoneCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final role = LocalStorage().readUser().role;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.errorContainer.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.error.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: cs.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign out",
                      style: tt.titleSmall!.copyWith(color: cs.error),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "You will need to log in again to access your account.",
                      style: tt.bodySmall!.copyWith(
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  LocalStorage().clearAll();
                  Get.offAll(() => const LoginScreen());
                },
                style: TextButton.styleFrom(
                  foregroundColor: cs.error,
                  backgroundColor: cs.error.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Logout",
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        if (role == 'vol') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.errorContainer.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.error.withOpacity(0.15), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.delete_forever_rounded, size: 20, color: cs.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delete Account",
                        style: tt.titleSmall!.copyWith(color: cs.error),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Submit a formal request to delete your NSS account.",
                        style: tt.bodySmall!.copyWith(
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    Get.to(() => DeleteAccountScreen());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: cs.error,
                    backgroundColor: cs.error.withOpacity(0.08),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Request Deletion",
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Theme.of(context).colorScheme.outline.withOpacity(.3),
    );
  }
}
