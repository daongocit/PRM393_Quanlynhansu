import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/leave_request_model.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/leave_request_provider.dart';

class LeaveRequestDetailScreen extends StatefulWidget {
  final LeaveRequest request;

  const LeaveRequestDetailScreen({super.key, required this.request});

  @override
  State<LeaveRequestDetailScreen> createState() =>
      _LeaveRequestDetailScreenState();
}

class _LeaveRequestDetailScreenState extends State<LeaveRequestDetailScreen> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final auth = Provider.of<AuthProvider>(context);
    final leaveProv = Provider.of<LeaveRequestProvider>(context);
    final user = auth.currentUser;

    final isPending = req.status == 'PENDING';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi Tiết Đơn Từ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
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
                      Text(
                        req.typeDisplay,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      StatusBadge(status: req.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã số đơn: #LR-${req.id}  •  Gửi lúc: ${req.createdAt}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Thời gian xin:', '${req.fromDate} đến ${req.toDate}'),
                  _buildDetailRow('Số ngày nghỉ:', '${req.totalDays} ngày'),
                  const SizedBox(height: 12),
                  const Text(
                    'Lý do chi tiết:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Timeline phê duyệt đa cấp
            const Text(
              'Tiến trình phê duyệt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildTimelineStep(
                    title: '1. Nhân viên nộp đơn online',
                    subtitle: 'Đã gửi lúc: ${req.createdAt}',
                    isCompleted: true,
                    isCurrent: false,
                  ),
                  _buildTimelineStep(
                    title: '2. Cấp Quản lý / Trưởng phòng thẩm định',
                    subtitle: req.status == 'PENDING'
                        ? 'Đang chờ Trưởng phòng xem xét'
                        : (req.status == 'APPROVED'
                            ? 'Đã duyệt: "${req.managerComment ?? ""}"'
                            : (req.status == 'REJECTED'
                                ? 'Từ chối: "${req.managerComment ?? ""}"'
                                : 'Đã hủy đơn')),
                    isCompleted: req.status == 'APPROVED',
                    isCurrent: req.status == 'PENDING',
                    isRejected: req.status == 'REJECTED',
                  ),
                  _buildTimelineStep(
                    title: '3. Hoàn tất & Trừ hạn mức phép',
                    subtitle: req.status == 'APPROVED'
                        ? 'Đã trừ vào quỹ phép cá nhân thành công'
                        : 'Chưa hoàn tất',
                    isCompleted: req.status == 'APPROVED',
                    isCurrent: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Nút Hủy đơn nếu còn PENDING
            if (isPending)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: _isCancelling
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.error),
                        )
                      : const Text('Hủy bỏ đơn này'),
                  onPressed: _isCancelling
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xác nhận hủy đơn'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn hủy đơn từ này?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Đóng'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Hủy đơn'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && user != null && req.id != null) {
                            setState(() => _isCancelling = true);
                            await leaveProv.cancelRequest(req.id!, user);
                            setState(() => _isCancelling = false);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã hủy đơn thành công!'),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    bool isRejected = false,
    bool isLast = false,
  }) {
    Color circleColor = Colors.grey[300]!;
    IconData icon = Icons.circle;

    if (isCompleted) {
      circleColor = AppColors.success;
      icon = Icons.check_circle;
    } else if (isRejected) {
      circleColor = AppColors.error;
      icon = Icons.cancel;
    } else if (isCurrent) {
      circleColor = AppColors.warning;
      icon = Icons.hourglass_top;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: circleColor, size: 22),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.success : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isCurrent ? AppColors.warning : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
