import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/leave_request_model.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/database/app_database.dart';
import '../../auth/providers/auth_provider.dart';
import '../../leave_requests/services/leave_calculator.dart';
import '../providers/approval_provider.dart';

class ManagerApprovalDetailScreen extends StatefulWidget {
  final LeaveRequest request;

  const ManagerApprovalDetailScreen({super.key, required this.request});

  @override
  State<ManagerApprovalDetailScreen> createState() => _ManagerApprovalDetailScreenState();
}

class _ManagerApprovalDetailScreenState extends State<ManagerApprovalDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  LeaveBalanceResult? _applicantBalance;
  bool _isLoadingQuota = true;

  @override
  void initState() {
    super.initState();
    _loadApplicantQuota();
  }

  Future<void> _loadApplicantQuota() async {
    try {
      final user = await AppDatabase.instance.getUserById(widget.request.userId);
      if (user != null) {
        final allUserRequests = await AppDatabase.instance.getUserLeaveRequests(user.id);
        final balance = LeaveCalculatorEngine.calculateBalance(user, allUserRequests);
        setState(() {
          _applicantBalance = balance;
          _isLoadingQuota = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingQuota = false);
    }
  }

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

    // Nhận diện vai trò Giám đốc (Trần Thảo)
    final bool isDirector = user?.position.toLowerCase().contains('giám đốc') == true ||
        user?.email == 'tranhr@company.com' ||
        user?.departmentId == 2;

    final bool isTier2Waiting = req.status == 'PENDING_TIER_2';
    final bool isTier1Pending = req.status == 'PENDING';
    final bool isActionable = isTier1Pending || (isTier2Waiting && isDirector);

    // Xác định nhãn nút duyệt
    String approveButtonLabel = 'Phê duyệt';
    if (req.totalDays > 2) {
      if (isDirector) {
        approveButtonLabel = 'Phê chuẩn (Cấp 2)';
      } else {
        approveButtonLabel = 'Thẩm định Cấp 1';
      }
    } else {
      approveButtonLabel = 'Phê duyệt (1 cấp)';
    }

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
            // Thông tin nhân viên nộp đơn
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
                        const SizedBox(height: 6),
                        StatusBadge(status: req.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // THẺ THẨM ĐỊNH QUOTA PHÉP & THÂM NIÊN
            if (req.requestType == 'ANNUAL_LEAVE')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Thẩm định Quỹ phép nhân sự',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingQuota)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_applicantBalance != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuotaMiniCard(
                              'Hạn mức tích lũy',
                              '${_applicantBalance!.accruedDays.toStringAsFixed(0)} ngày',
                              'Thâm niên ${_applicantBalance!.tenureMonths} tháng',
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuotaMiniCard(
                              'Đã sử dụng',
                              '${_applicantBalance!.usedDays.toStringAsFixed(0)} ngày',
                              'Đã duyệt nghỉ',
                              AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuotaMiniCard(
                              'Khả dụng còn lại',
                              '${_applicantBalance!.remainingDays.toStringAsFixed(0)} ngày',
                              _applicantBalance!.remainingDays >= req.totalDays
                                  ? 'ĐỦ ĐIỀU KIỆN'
                                  : 'VƯỢT HẠN MỨC',
                              _applicantBalance!.remainingDays >= req.totalDays
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      if (_applicantBalance!.remainingDays < req.totalDays) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Cảnh báo: Nhân viên xin ${req.totalDays} ngày nhưng chỉ còn ${_applicantBalance!.remainingDays} ngày phép!',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Chi tiết nội dung đơn
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Loại đơn:', req.typeDisplay, isBold: true),
                  _buildDetailRow('Từ ngày:', req.fromDate),
                  _buildDetailRow('Đến ngày:', req.toDate),
                  _buildDetailRow('Số ngày nghỉ:', '${req.totalDays} ngày', isBold: true),
                  _buildDetailRow('Thời gian gửi:', req.createdAt),
                  const Divider(height: 20),
                  const Text(
                    'Lý do nộp đơn:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      req.reason.isNotEmpty ? req.reason : 'Không có lý do chi tiết.',
                      style: const TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Business Rule Badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LeaveCalculatorEngine.requiresMultiTierApproval(req.totalDays)
                    ? const Color(0xFFFEF3C7)
                    : AppColors.infoBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: LeaveCalculatorEngine.requiresMultiTierApproval(req.totalDays)
                      ? const Color(0xFFFDE68A)
                      : AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LeaveCalculatorEngine.requiresMultiTierApproval(req.totalDays)
                        ? Icons.alt_route_rounded
                        : Icons.info_outline,
                    color: LeaveCalculatorEngine.requiresMultiTierApproval(req.totalDays)
                        ? const Color(0xFFD97706)
                        : AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LeaveCalculatorEngine.requiresMultiTierApproval(req.totalDays)
                          ? 'Business Rule: Đơn > 2 ngày (${req.totalDays} ngày) yêu cầu phê duyệt 2 cấp (Trưởng bộ phận thẩm định → Giám đốc phê chuẩn).'
                          : 'Business Rule: Đơn ≤ 2 ngày (${req.totalDays} ngày) được phê duyệt trực tiếp 1 bước bởi Trưởng phòng.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BANNER ĐẶC BIỆT: NẾU ĐÃ THẨM ĐỊNH CẤP 1 VÀ ĐANG CHỜ GIÁM ĐỐC DUYỆT
            if (isTier2Waiting && !isDirector) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Color(0xFFD97706), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'CẤP 1 ĐÃ THẨM ĐỊNH XONG',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFFB45309)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ghi chú thẩm định: "${req.managerComment ?? ""}"',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '⏳ Đơn nghỉ dài ngày (> 2 ngày) hiện đang chờ Giám đốc Nhân sự (Trần Thảo) phê chuẩn Cấp 2 mới hoàn tất.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF92400E), height: 1.3),
                    ),
                  ],
                ),
              ),
            ] else if (isTier2Waiting && isDirector) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'CHỜ PHÊ CHUẨN CẤP 2 (GIÁM ĐỐC NHÂN SỰ)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF065F46)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trưởng phòng đã thẩm định: "${req.managerComment ?? ""}"',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF047857)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Bạn đang xem đơn với tư cách Giám đốc Trần Thảo. Vui lòng xem xét và bấm nút Phê chuẩn (Cấp 2) bên dưới.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
              ),
            ],

            // Form nhận xét & Action Buttons (Approve / Reject)
            if (isActionable) ...[
              Text(
                isDirector && isTier2Waiting
                    ? 'Ý kiến phê chuẩn của Giám đốc (Trần Thảo):'
                    : 'Nhận xét / Ý kiến phản hồi của Quản lý:',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isDirector && isTier2Waiting
                      ? 'Nhập ý kiến phê chuẩn của Giám đốc...'
                      : 'Nhập ghi chú hoặc lý do từ chối (nếu có)...',
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
                                  approverName: user.fullName,
                                );
                                if (context.mounted) {
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
                      label: Text(
                        approveButtonLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setState(() => _isSubmitting = true);
                              if (user != null && req.id != null) {
                                await approvalProv.approveSingle(
                                  req.id!,
                                  user.id,
                                  isDirector: isDirector,
                                  approverName: user.fullName,
                                  comment: _commentController.text.trim().isNotEmpty
                                      ? _commentController.text.trim()
                                      : (isDirector ? 'Đồng ý phê chuẩn.' : 'Đồng ý duyệt.'),
                                );
                                if (context.mounted) {
                                  final msg = (req.totalDays > 2 && !isDirector)
                                      ? 'Đã hoàn tất thẩm định Cấp 1! Đơn chuyển tiếp Giám đốc Trần Thảo phê chuẩn Cấp 2.'
                                      : 'Đã phê duyệt đơn thành công!';

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(msg),
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
            ] else if (req.status != 'PENDING' && req.status != 'PENDING_TIER_2') ...[
              // Đã xử lý hoàn tất (APPROVED / REJECTED)
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
                      'Kết quả thẩm định & Phê duyệt:',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Người xử lý cuối: ${req.approverName ?? "Quản lý"}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ghi chú tiến trình:\n${req.managerComment ?? "Không có ghi chú"}',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.3),
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

  Widget _buildQuotaMiniCard(String title, String mainValue, String subValue, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(mainValue, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(subValue, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
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


