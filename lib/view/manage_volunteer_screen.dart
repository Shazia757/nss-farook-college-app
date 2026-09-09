import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/view/add_volunteer_screen.dart';
import 'package:nss_new/view/home_screen.dart';

class ManageVolunteerScreen extends StatefulWidget {
  const ManageVolunteerScreen({super.key});

  @override
  State<ManageVolunteerScreen> createState() => _ManageVolunteerScreenState();
}

class _ManageVolunteerScreenState extends State<ManageVolunteerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final VolunteerListController controller = Get.put(VolunteerListController());
  final VolunteerController volunteerController = Get.put(
    VolunteerController(),
  );

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

                if (currentList.isEmpty) {
                  return Center(
                    child: Text(
                      'No volunteers found',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (controller.isShowingPassive.value) {
                      controller.getPassiveData();
                    } else {
                      controller.getData();
                    }
                  },
                  child: ListView.separated(
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
                        child: ListTile(
                          onTap: () {
                            controller.viewVolunteerProfile(v.admissionNo);
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
                            "Admission No: ${v.admissionNo ?? ''}\n${v.department?.category ?? ''} ${v.department?.name ?? ''}"
                                .trim(),
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                            onSelected: (value) {
                              if (value == 'delete') {
                                CustomWidgets().showConfirmationDialog(
                                  title: "Delete Volunteer",
                                  message:
                                      "Are you sure you want to delete this volunteer?",
                                  onConfirm: () async {
                                    await volunteerController.deleteVolunteer(
                                      v.admissionNo ?? '',
                                    );
                                    controller.getData();
                                  },
                                  data: Obx(
                                    () =>
                                        volunteerController
                                            .isDeleteButtonLoading
                                            .value
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
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 12),
                                    Text('Delete volunteer'),
                                  ],
                                ),
                              ),
                            ],
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
