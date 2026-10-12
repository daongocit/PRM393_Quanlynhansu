import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/leave_request_provider.dart';

class CreateLeaveRequestScreen extends StatefulWidget {
  final String? initialType;

  const CreateLeaveRequestScreen({super.key, this.initialType});

  @override
  State<CreateLeaveRequestScreen> createState() =>
      _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState extends State<CreateLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  DateTime _fromDate = DateTime.now().add(const Duration(days: 1));
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  double _totalDays = 1.0;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _requestTypes = [
    {'value': 'ANNUAL_LEAVE', 'label': 'Nghỉ phép năm (Có hưởng lương)'},
    {'value': 'SICK_LEAVE', 'label': 'Nghỉ ốm đau (Hưởng BHXH)'},
    {'value': 'UNPAID_LEAVE', 'label': 'Nghỉ không lương'},
    {'value': 'LATE_EXPLANATION', 'label': 'Giải trình đi trễ / Quên quẹt thẻ'},
    {'value': 'SHIFT_SWAP', 'label': 'Xin đổi ca làm việc'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? 'ANNUAL_LEAVE';
    _recalculateDays();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _recalculateDays() {
    final diff = _toDate.difference(_fromDate).inDays + 1;
    setState(() {
      _totalDays = diff > 0 ? diff.toDouble() : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final leaveProv = Provider.of<LeaveRequestProvider>(context);
    final user = auth.currentUser;
    final remainingDays = leaveProv.balance?.remainingDays ?? 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lập Đơn Xin Nghỉ & Đơn Từ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin hạn mức phép năm hiện có
              if (_selectedType == 'ANNUAL_LEAVE')
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hạn mức phép năm khả dụng: $remainingDays ngày.\n(Lưu ý: Nếu nộp vượt quá hạn mức, hệ thống sẽ yêu cầu chuyển sang nghỉ không lương).',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Loại đơn từ
              const Text(
                'Loại đơn từ',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(),
                items: _requestTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),

              const SizedBox(height: 20),

              // Chọn ngày Từ ngày - Đến ngày
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Từ ngày',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fromDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 7)),
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                            );
                            if (picked != null) {
                              setState(() {
                                _fromDate = picked;
                                if (_toDate.isBefore(_fromDate)) {
                                  _toDate = _fromDate;
                                }
                                _recalculateDays();
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(DateFormat('dd/MM/yyyy').format(_fromDate)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đến ngày',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _toDate,
                              firstDate: _fromDate,
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                            );
                            if (picked != null) {
                              setState(() {
                                _toDate = picked;
                                _recalculateDays();
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(DateFormat('dd/MM/yyyy').format(_toDate)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tổng số ngày tính tự động
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng số ngày nghỉ tính toán:'),
                    Text(
                      '$_totalDays ngày',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Lý do xin nghỉ
              const Text(
                'Lý do chi tiết',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Nhập rõ lý do xin nghỉ hoặc giải trình...',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập lý do cụ thể';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Nút Gửi đơn với Business Rule Validation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Gửi đơn phê duyệt',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          if (user == null) return;

                          setState(() => _isSubmitting = true);

                          // Gọi submit qua Provider và nhận kết quả Business Rule Validation
                          final error = await leaveProv.submitLeaveRequest(
                            user: user,
                            requestType: _selectedType,
                            fromDate: _fromDate,
                            toDate: _toDate,
                            totalDays: _totalDays,
                            reason: _reasonController.text.trim(),
                          );

                          setState(() => _isSubmitting = false);

                          if (error != null) {
                            // Vi phạm Business Rule
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: AppColors.error),
                                      SizedBox(width: 8),
                                      Text('Quy tắc nghiệp vụ'),
                                    ],
                                  ),
                                  content: Text(error),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Đã hiểu'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            // Thành công
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã nộp đơn thành công! Đang chờ Quản lý phê duyệt.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              Navigator.pop(context);
                            }
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
}
