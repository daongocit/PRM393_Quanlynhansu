import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../providers/task_provider.dart';

class TaskReminderScreen extends StatefulWidget {
  final TaskItem task;

  const TaskReminderScreen({super.key, required this.task});

  @override
  State<TaskReminderScreen> createState() => _TaskReminderScreenState();
}

class _TaskReminderScreenState extends State<TaskReminderScreen> {
  final _noteController = TextEditingController();
  DateTime _reminderDate = DateTime.now();
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _noteController.text = 'Nhắc nhở hoàn thiện công việc: ${widget.task.title}';
    if (widget.task.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<TaskProvider>(context, listen: false)
            .loadReminders(widget.task.id!);
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _setPresetReminder(Duration beforeDeadline) {
    try {
      final deadline = DateTime.parse(widget.task.deadline);
      final target = deadline.subtract(beforeDeadline);
      setState(() {
        _reminderDate = target;
        _reminderTime = TimeOfDay(hour: target.hour, minute: target.minute);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đã chọn mốc: ${DateFormat('dd/MM/yyyy HH:mm').format(target)}'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final reminders = taskProv.getReminders(widget.task.id ?? 0);
    final reminderStr =
        '${DateFormat('yyyy-MM-dd').format(_reminderDate)} ${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thiết Lập Mốc Nhắc Nhở'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm_on, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Deadline: ${widget.task.deadline}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Các mốc nhắc nhở gợi ý nhanh
            const Text(
              'Gợi ý mốc nhắc nhở nhanh:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _setPresetReminder(const Duration(hours: 1)),
                    child: const Text('Trước 1h', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _setPresetReminder(const Duration(hours: 4)),
                    child: const Text('Trước 4h', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _setPresetReminder(const Duration(days: 1)),
                    child: const Text('Trước 1 ngày', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Form Tùy chọn ngày giờ
            const Text(
              'Thời gian nhắc nhở tùy chọn:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _reminderDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (d != null && mounted) {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                  );
                  if (t != null) {
                    setState(() {
                      _reminderDate = d;
                      _reminderTime = t;
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      reminderStr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Text('Thay đổi',
                        style: TextStyle(color: AppColors.primaryLight)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ghi chú nhắc nhở
            const Text(
              'Nội dung ghi chú chuông nhắc:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Nhập lời nhắc nhở cá nhân...',
              ),
            ),

            const SizedBox(height: 20),

            // Nút Lưu nhắc nhở & Kích hoạt Local Notification
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add_alert_rounded),
                label: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Thiết lập mốc nhắc nhở',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (widget.task.id == null) return;
                        setState(() => _isSaving = true);

                        await taskProv.addReminder(
                          taskId: widget.task.id!,
                          taskTitle: widget.task.title,
                          reminderTime: reminderStr,
                          note: _noteController.text.trim(),
                        );

                        setState(() => _isSaving = false);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Đã cài đặt chuông nhắc nhở và thông báo thành công!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
              ),
            ),

            const SizedBox(height: 30),

            // Danh sách các mốc nhắc nhở đã đặt cho task
            const Text(
              'Các mốc nhắc nhở đã thiết lập:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            if (reminders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Chưa có mốc nhắc nào được đặt cho nhiệm vụ này.',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final rem = reminders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm, color: AppColors.accent, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rem.reminderTime,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rem.note,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error, size: 20),
                          onPressed: () async {
                            if (rem.id != null && widget.task.id != null) {
                              await taskProv.deleteReminder(widget.task.id!, rem.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
