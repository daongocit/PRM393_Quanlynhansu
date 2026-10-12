import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../../../core/widgets/status_badge.dart';
import '../providers/task_provider.dart';
import 'task_comments_screen.dart';
import 'task_reminder_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskItem task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late double _currentProgress;
  late String _currentStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.task.progressPercent.toDouble();
    _currentStatus = widget.task.status;
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final task = widget.task;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi Tiết Nhiệm Vụ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: task.priority == 'HIGH'
                              ? AppColors.errorBg
                              : AppColors.infoBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.priorityDisplay.toUpperCase(),
                          style: TextStyle(
                            color: task.priority == 'HIGH'
                                ? AppColors.error
                                : AppColors.info,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      StatusBadge(status: _currentStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Người phụ trách:',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            task.assigneeName ?? 'Chưa gán',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Hạn chót (Deadline):',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            task.deadline,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: task.isOverdue
                                  ? AppColors.error
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TIẾN ĐỘ & CẬP NHẬT TRẠNG THÁI (SLIDER)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cập nhật tiến độ hoàn thành',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_currentProgress.toInt()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _currentProgress,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.cardBorder,
                    label: '${_currentProgress.toInt()}%',
                    onChanged: (val) {
                      setState(() {
                        _currentProgress = val;
                        if (_currentProgress == 100) {
                          _currentStatus = 'DONE';
                        } else if (_currentProgress > 0) {
                          _currentStatus = 'IN_PROGRESS';
                        } else {
                          _currentStatus = 'TODO';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trạng thái hiện tại:'),
                      DropdownButton<String>(
                        value: _currentStatus,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                              value: 'TODO', child: Text('Chưa làm')),
                          DropdownMenuItem(
                              value: 'IN_PROGRESS', child: Text('Đang làm')),
                          DropdownMenuItem(
                              value: 'DONE', child: Text('Hoàn thành')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _currentStatus = val;
                              if (val == 'DONE') _currentProgress = 100;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (task.id == null) return;
                              setState(() => _isSaving = true);
                              await taskProv.updateTaskProgress(
                                taskId: task.id!,
                                newStatus: _currentStatus,
                                progressPercent: _currentProgress.toInt(),
                              );
                              setState(() => _isSaving = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã cập nhật tiến độ công việc!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      child: const Text('Lưu tiến độ'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2 PHÍM ĐIỀU HƯỚNG LIÊN THÔNG ĐẶC TRƯNG:
            // Màn 14: BÌNH LUẬN NỘI BỘ & Màn 15: ĐẶT MỐC NHẮC NHỞ
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (task.id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskCommentsScreen(task: task),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.forum_outlined,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Thảo Luận Task',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Comment phòng ban',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (task.id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskReminderScreen(task: task),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notification_add_outlined,
                                color: AppColors.accent, size: 24),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Đặt Mốc Nhắc',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Hẹn giờ & Notification',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
