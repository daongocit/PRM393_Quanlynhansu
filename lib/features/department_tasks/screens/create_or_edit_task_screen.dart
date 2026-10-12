import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/task_provider.dart';

class CreateOrEditTaskScreen extends StatefulWidget {
  final TaskItem? taskToEdit;

  const CreateOrEditTaskScreen({super.key, this.taskToEdit});

  @override
  State<CreateOrEditTaskScreen> createState() => _CreateOrEditTaskScreenState();
}

class _CreateOrEditTaskScreenState extends State<CreateOrEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  int? _selectedAssigneeId;
  String _selectedPriority = 'MEDIUM';
  DateTime _deadlineDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _deadlineTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description;
      _selectedAssigneeId = widget.taskToEdit!.assigneeId;
      _selectedPriority = widget.taskToEdit!.priority;
      try {
        final parsed = DateTime.parse(widget.taskToEdit!.deadline);
        _deadlineDate = parsed;
        _deadlineTime = TimeOfDay(hour: parsed.hour, minute: parsed.minute);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final taskProv = Provider.of<TaskProvider>(context);
    final user = auth.currentUser;
    final deptUsers = auth.availableUsers
        .where((u) => u.departmentId == (user?.departmentId ?? 1))
        .toList();

    if (_selectedAssigneeId == null && deptUsers.isNotEmpty) {
      _selectedAssigneeId = deptUsers.first.id;
    }

    final deadlineString =
        '${DateFormat('yyyy-MM-dd').format(_deadlineDate)} ${_deadlineTime.hour.toString().padLeft(2, '0')}:${_deadlineTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.taskToEdit == null ? 'Giao Công Việc Mới' : 'Chỉnh Sửa Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              const Text('Tiêu đề công việc *',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tên công việc cần triển khai...',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập tiêu đề task';
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Mô tả
              const Text('Mô tả chi tiết & Yêu cầu bàn giao',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Mô tả rõ yêu cầu mục tiêu, checklist công việc...',
                ),
              ),

              const SizedBox(height: 18),

              // Người thực hiện (Assignee cùng phòng ban)
              const Text('Người thực hiện (Assignee)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedAssigneeId,
                decoration: const InputDecoration(),
                items: deptUsers.map((u) {
                  return DropdownMenuItem<int>(
                    value: u.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(u.avatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Text('${u.fullName} (${u.position})'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAssigneeId = val);
                },
              ),

              const SizedBox(height: 18),

              // Mức độ ưu tiên
              const Text('Mức độ ưu tiên (Priority)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip('HIGH', 'Khẩn cấp', AppColors.error),
                  const SizedBox(width: 10),
                  _buildPriorityChip('MEDIUM', 'Trung bình', AppColors.warning),
                  const SizedBox(width: 10),
                  _buildPriorityChip('LOW', 'Thấp', AppColors.secondary),
                ],
              ),

              const SizedBox(height: 20),

              // Deadline Hạn chót
              const Text('Hạn chót hoàn thành (Deadline) *',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _deadlineDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (pickedDate != null && mounted) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _deadlineTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _deadlineDate = pickedDate;
                        _deadlineTime = pickedTime;
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
                      const Icon(Icons.event_available, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        deadlineString,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Text('Chọn lại', style: TextStyle(color: AppColors.primaryLight)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Nút Tạo task
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.taskToEdit == null ? 'Tạo công việc' : 'Lưu thay đổi',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          if (user == null || _selectedAssigneeId == null) return;

                          setState(() => _isSubmitting = true);

                          final newTask = TaskItem(
                            id: widget.taskToEdit?.id,
                            title: _titleController.text.trim(),
                            description: _descController.text.trim(),
                            departmentId: user.departmentId,
                            creatorId: user.id,
                            assigneeId: _selectedAssigneeId!,
                            priority: _selectedPriority,
                            status: widget.taskToEdit?.status ?? 'TODO',
                            progressPercent: widget.taskToEdit?.progressPercent ?? 0,
                            deadline: deadlineString,
                            createdAt: DateFormat('yyyy-MM-dd HH:mm')
                                .format(DateTime.now()),
                          );

                          if (widget.taskToEdit == null) {
                            await taskProv.createTask(newTask);
                          }

                          setState(() => _isSubmitting = false);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã lưu công việc thành công!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String key, String label, Color color) {
    final isSelected = _selectedPriority == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : AppColors.cardBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
