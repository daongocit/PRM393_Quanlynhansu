import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/task_provider.dart';
import 'create_or_edit_task_screen.dart';
import 'task_detail_screen.dart';

class DepartmentTaskBoardScreen extends StatefulWidget {
  const DepartmentTaskBoardScreen({super.key});

  @override
  State<DepartmentTaskBoardScreen> createState() =>
      _DepartmentTaskBoardScreenState();
}

class _DepartmentTaskBoardScreenState extends State<DepartmentTaskBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<TaskProvider>(context, listen: false).loadDepartmentTasks(
          auth.currentUser!.departmentId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final tasks = taskProv.filteredTasks;

    final todoCount =
        taskProv.departmentTasks.where((t) => t.status == 'TODO').length;
    final inProgressCount =
        taskProv.departmentTasks.where((t) => t.status == 'IN_PROGRESS').length;
    final doneCount =
        taskProv.departmentTasks.where((t) => t.status == 'DONE').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.primaryGlow,
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_task_rounded, color: Colors.white),
          label: const Text(
            'Giao việc mới',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateOrEditTaskScreen(),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppHeader(
              title: 'Công Việc Phòng Ban',
              subtitle: 'Theo dõi tiến độ, phân công nhiệm vụ & trao đổi nội bộ',
              actions: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: IconButton(
                    tooltip: 'Tạo công việc mới',
                    icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateOrEditTaskScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Kanban Status Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildTabBadge('Tất cả', '${taskProv.departmentTasks.length}', 'ALL', taskProv),
                  const SizedBox(width: 8),
                  _buildTabBadge('Chưa làm', '$todoCount', 'TODO', taskProv),
                  const SizedBox(width: 8),
                  _buildTabBadge('Đang làm', '$inProgressCount', 'IN_PROGRESS', taskProv),
                  const SizedBox(width: 8),
                  _buildTabBadge('Hoàn thành', '$doneCount', 'DONE', taskProv),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'Không có công việc nào trong danh mục này.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final isHighPriority = task.priority == 'HIGH';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskDetailScreen(task: task),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Priority Badge & Status
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isHighPriority
                                              ? AppColors.errorBg
                                              : AppColors.infoBg,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          task.priorityDisplay.toUpperCase(),
                                          style: TextStyle(
                                            color: isHighPriority
                                                ? AppColors.error
                                                : AppColors.info,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      StatusBadge(status: task.status),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Title
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    task.description,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 12),

                                  // Progress Bar
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Tiến độ:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          Text(
                                            '${task.progressPercent}%',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: task.progressPercent / 100.0,
                                          backgroundColor: AppColors.cardBorder,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            task.progressPercent == 100
                                                ? AppColors.success
                                                : AppColors.primary,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),

                                  // Footer: Assignee & Deadline & Comments
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundImage: task.assigneeAvatar !=
                                                    null
                                                ? NetworkImage(
                                                    task.assigneeAvatar!)
                                                : null,
                                            child: task.assigneeAvatar == null
                                                ? const Icon(Icons.person,
                                                    size: 14)
                                                : null,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            task.assigneeName ?? 'Người làm',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.alarm,
                                            size: 14,
                                            color: task.isOverdue
                                                ? AppColors.error
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            task.deadline,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: task.isOverdue
                                                  ? AppColors.error
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.chat_bubble_outline,
                                              size: 14,
                                              color: AppColors.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${task.commentCount}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBadge(
      String label, String count, String filterKey, TaskProvider prov) {
    final isSelected = prov.selectedStatusFilter == filterKey;
    return GestureDetector(
      onTap: () => prov.setStatusFilter(filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1.2,
          ),
          boxShadow: isSelected ? AppColors.primaryGlow : AppColors.softShadow,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.22) : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
