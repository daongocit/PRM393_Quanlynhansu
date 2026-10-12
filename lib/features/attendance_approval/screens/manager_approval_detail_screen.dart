import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/leave_request_model.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/approval_provider.dart';

class ManagerApprovalDetailScreen extends StatefulWidget {
  final LeaveRequest request;

  const ManagerApprovalDetailScreen({super.key, required this.request});

  @override
  State<ManagerApprovalDetailScreen> createState() =>
      _ManagerApprovalDetailScreenState();
}

class _ManagerApprovalDetailScreenState
    extends State<ManagerApprovalDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final auth = Provider.of<AuthProvider>(context);
    final approvalProv = Provider.of<ApprovalProvider>(context);
    final user = auth.currentUser;

    final isPending = req.status == 'PENDING';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thẩm Định & Phê Duyệt'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin nhân viên
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: req.userAvatar != null
                        ? NetworkImage(req.userAvatar!)
                        : null,
                    child: req.userAvatar == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.userName ?? 'Nhân sự',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${req.departmentName ?? "Phòng ban"} - Mã đơn #${req.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: req.status),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Thông tin chi tiết đơn từ
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
                  const Text(
                    'Chi tiết nội dung đơn từ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Loại đơn:', req.typeDisplay, isBold: true),
                  _buildDetailRow('Thời gian nghỉ:', '${req.fromDate} đến ${req.toDate}'),
                  _buildDetailRow('Tổng số ngày xin:', '${req.totalDays} ngày'),
                  _buildDetailRow('Ngày gửi đơn:', req.createdAt),
                  const SizedBox(height: 12),
                  const Text(
                    'Lý do xin nghỉ:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      req.reason,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Đánh giá Quỹ phép / Business rule info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Business Rule: Đơn nghỉ dưới 2 ngày được phê duyệt ngay 1 cấp bởi Trưởng phòng.',
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form nhận xét của Quản lý
            if (isPending) ...[
              const Text(
                'Nhận xét / Ý kiến phản hồi của Quản lý:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Nhập ghi chú hoặc lý do từ chối (nếu có)...',
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons: Reject & Approve
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Từ chối'),
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (_commentController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng nhập lý do từ chối đơn!'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              setState(() => _isSubmitting = true);
                              if (user != null && req.id != null) {
                                await approvalProv.rejectSingle(
                                  req.id!,
                                  user.id,
                                  reason: _commentController.text.trim(),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã từ chối đơn thành công!'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Phê duyệt'),
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setState(() => _isSubmitting = true);
                              if (user != null && req.id != null) {
                                await approvalProv.approveSingle(
                                  req.id!,
                                  user.id,
                                  comment: _commentController.text.trim().isNotEmpty
                                      ? _commentController.text.trim()
                                      : 'Đồng ý duyệt đơn.',
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã phê duyệt đơn thành công!'),
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
            ] else ...[
              // Đã xử lý
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kết quả thẩm định:',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Người duyệt: ${req.approverName ?? "Quản lý"}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phản hồi: "${req.managerComment ?? "Không có ghi chú"}"',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
