import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/view/volunteer/add_volunteer_screen.dart';
import 'package:nss_new/view/home_screen.dart';

class ManageVolunteerScreen extends StatefulWidget {
  const ManageVolunteerScreen({super.key});

  @override
  State<ManageVolunteerScreen> createState() => _ManageVolunteerScreenState();
}

class _ManageVolunteerScreenState extends State<ManageVolunteerScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final VolunteerListController controller;
  late final VolunteerController volunteerController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<VolunteerListController>()
        ? Get.find<VolunteerListController>()
        : Get.put(VolunteerListController());
    volunteerController = Get.isRegistered<VolunteerController>()
        ? Get.find<VolunteerController>()
        : Get.put(VolunteerController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.isShowingPassive.value) {
        controller.getPassiveData();
      } else {
        controller.getData();
      }
      controller.fetchBatches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, Volunteer v) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final admn = v.admissionNo;
    if (admn == null || admn.isEmpty) return;

    CustomWidgets().showConfirmationDialog(
      title: "Delete Volunteer",
      message: "This action is permanent and cannot be undone.",
      content: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.errorContainer.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.error.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Permanently delete volunteer record?",
                    style: tt.labelLarge?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Name: ${v.name ?? 'Not provided'}",
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              "Admission No: $admn",
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            if (v.department != null) ...[
              const SizedBox(height: 2),
              Text(
                "Department: ${v.department?.category ?? ''} ${v.department?.name ?? ''}"
                    .trim(),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
      onConfirm: () async {
        final success = await volunteerController.deleteVolunteer(admn);
        if (success) {
          controller.removeVolunteerLocally(admn);
        }
      },
      data: Obx(
        () => volunteerController.isDeleteButtonLoading.value
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
            : const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddVolunteerScreen())?.then((_) {
            if (controller.isShowingPassive.value) {
              controller.getPassiveData();
            } else {
              controller.getData();
            }
          });
        },
        backgroundColor: cs.primary,
        child: const Icon(Icons.person_add_alt, color: Colors.white),
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
                          suffixIcon: _searchController.text.isNotEmpty
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Volunteers',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Manage, track and oversee volunteer records.',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Obx(() {
                    final isPassive = controller.isShowingPassive.value;

                    return Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _VolunteerToggleButton(
                              label: 'Active',
                              icon: Icons.check_circle_outline_rounded,
                              selected: !isPassive,
                              onTap: () {
                                controller.togglePassiveView(false);
                              },
                            ),
                          ),
                          Expanded(
                            child: _VolunteerToggleButton(
                              label: 'Passive',
                              icon: Icons.pause_circle_outline_rounded,
                              selected: isPassive,
                              onTap: () {
                                controller.togglePassiveView(true);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  Obx(() {
                    final isPassive = controller.isShowingPassive.value;

                    final count = isPassive
                        ? controller.passiveUsersList.length
                        : controller.usersList.length;

                    return StatCard(
                      title: isPassive
                          ? 'Passive Volunteers'
                          : 'Active Volunteers',
                      value: count.toString(),
                      icon: Icons.people_outline_rounded,
                      backgroundColor: cs.onPrimary,
                      textColor: cs.onSurface,
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final isCurrentLoading = controller.isShowingPassive.value
                    ? controller.isPassiveLoading.value
                    : controller.isLoading.value;

                if (isCurrentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final currentList = controller.isShowingPassive.value
                    ? controller.passiveUsersList
                    : controller.usersList;

                return RefreshIndicator(
                  onRefresh: () async {
                    if (controller.isShowingPassive.value) {
                      controller.getPassiveData();
                    } else {
                      controller.getData();
                    }
                  },
                  child: currentList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.group_off_outlined,
                                      size: 56,
                                      color: cs.onSurface.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      controller.searchQuery.value.isNotEmpty
                                          ? 'No volunteers matching "${controller.searchQuery.value}"'
                                          : 'No volunteers found',
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
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: currentList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final v = currentList[index];
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
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    controller.viewVolunteerProfile(
                                      v.admissionNo,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: cs.primary
                                                  .withOpacity(0.12),
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
                                                          v.name ?? '',
                                                          style: tt.bodyMedium
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
                                                      if (v.bloodGroup !=
                                                              null &&
                                                          v
                                                              .bloodGroup!
                                                              .isNotEmpty) ...[
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
                                                            v.bloodGroup!,
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
                                                    "Admission No: ${v.admissionNo ?? 'N/A'}",
                                                    style: tt.bodySmall
                                                        ?.copyWith(
                                                          color: cs.onSurface
                                                              .withOpacity(
                                                                0.65,
                                                              ),
                                                        ),
                                                  ),
                                                  Text(
                                                    "${v.department?.category ?? ''} ${v.department?.name ?? ''}"
                                                        .trim(),
                                                    style: tt.bodySmall
                                                        ?.copyWith(
                                                          color: cs.onSurface
                                                              .withOpacity(
                                                                0.55,
                                                              ),
                                                          fontSize: 11,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                          height: 1,
                                          thickness: 0.7,
                                          color: cs.outline.withOpacity(0.15),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                foregroundColor: cs.primary,
                                              ),
                                              onPressed: () {
                                                controller.viewVolunteerProfile(
                                                  v.admissionNo,
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.visibility_outlined,
                                                size: 15,
                                              ),
                                              label: const Text(
                                                'View',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                foregroundColor: cs.secondary,
                                              ),
                                              onPressed: () {
                                                controller.updateVolunteer(
                                                  v.admissionNo,
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 15,
                                              ),
                                              label: const Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                foregroundColor: cs.error,
                                              ),
                                              onPressed: () {
                                                _showDeleteConfirmation(
                                                  context,
                                                  v,
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                size: 15,
                                                color: cs.error,
                                              ),
                                              label: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: cs.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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

class _VolunteerToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VolunteerToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
