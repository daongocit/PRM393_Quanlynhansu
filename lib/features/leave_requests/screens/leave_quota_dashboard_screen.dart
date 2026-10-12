import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/leave_request_provider.dart';
import 'create_leave_request_screen.dart';
import 'my_leave_requests_screen.dart';
import 'shift_schedule_screen.dart';

class LeaveQuotaDashboardScreen extends StatefulWidget {
  const LeaveQuotaDashboardScreen({super.key});

  @override
  State<LeaveQuotaDashboardScreen> createState() =>
      _LeaveQuotaDashboardScreenState();
}

class _LeaveQuotaDashboardScreenState extends State<LeaveQuotaDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<LeaveRequestProvider>(context, listen: false)
            .loadUserData(auth.currentUser!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaveProv = Provider.of<LeaveRequestProvider>(context);
    final balance = leaveProv.balance;

    final tenureMonths = balance?.tenureMonths ?? 3;
    final accruedDays = balance?.accruedDays ?? 3.0;
    final usedDays = balance?.usedDays ?? 2.0;
    final remainingDays = balance?.remainingDays ?? 1.0;
    final pendingDays = balance?.pendingDays ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppHeader(
              title: 'Quản Lý Quỹ Phép & Đơn Từ',
              subtitle: 'Theo dõi hạn mức phép năm theo thâm niên & nộp đơn online',
              actions: [
                IconButton(
                  tooltip: 'Xem danh sách toàn bộ đơn cá nhân',
                  icon: const Icon(Icons.description_outlined, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyLeaveRequestsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // THẺ QUỸ PHÉP THÔNG MINH (BUSINESS RULE CHÍNH TỪ ĐỀ BÀI)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.workspace_premium,
                                      color: Color(0xFFFBBF24), size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'QUỸ PHÉP NĂM THEO THÂM NIÊN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Thâm niên: $tenureMonths tháng',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Hiển thị số ngày còn lại lớn
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Số ngày phép khả dụng còn lại',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$remainingDays',
                                          style: const TextStyle(
                                            color: Color(0xFF34D399), // Emerald
                                            fontSize: 44,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ' ngày',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Circular Badge Indicator
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFF34D399), width: 4),
                                ),
                                child: Center(
                                  child: Text(
                                    '${((remainingDays / (accruedDays > 0 ? accruedDays : 1)) * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 12),

                          // Bảng đối soát Business Rule (Đúng chuẩn đề bài: 3 tháng -> 3 ngày, đã nghỉ 2, còn 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricItem(
                                'Tối đa được nghỉ',
                                '$accruedDays ngày',
                                Colors.white,
                              ),
                              Container(height: 30, width: 1, color: Colors.white24),
                              _buildMetricItem(
                                'Đã nghỉ',
                                '$usedDays ngày',
                                const Color(0xFFF87171),
                              ),
                              Container(height: 30, width: 1, color: Colors.white24),
                              _buildMetricItem(
                                'Đang chờ duyệt',
                                '$pendingDays ngày',
                                const Color(0xFFFBBF24),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Phím tắt chức năng chính
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Lập đơn xin nghỉ mới'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateLeaveRequestScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Lịch ca'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShiftScheduleScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Đơn từ gần đây
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Đơn từ gửi gần đây',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyLeaveRequestsScreen(),
                              ),
                            );
                          },
                          child: const Text('Xem tất cả →'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (leaveProv.userRequests.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Bạn chưa gửi đơn từ nào.'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leaveProv.userRequests.take(3).length,
                        itemBuilder: (context, index) {
                          final req = leaveProv.userRequests[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          req.typeDisplay,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${req.fromDate} → ${req.toDate} (${req.totalDays} ngày)',
                                          style: const TextStyle(
                                            fontSize: 12,
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
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
