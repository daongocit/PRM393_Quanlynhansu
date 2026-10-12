import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../constants/app_colors.dart';

class CustomAppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const CustomAppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 22,
                backgroundImage: user != null && user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                backgroundColor: AppColors.primaryLight,
                child: (user == null || user.avatarUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              // User Name & Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user?.fullName ?? 'Khách',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (user?.isManager ?? false)
                                ? AppColors.accent.withOpacity(0.12)
                                : AppColors.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (user?.isManager ?? false) ? 'QUẢN LÝ' : 'NHÂN VIÊN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: (user?.isManager ?? false)
                                  ? AppColors.accent
                                  : AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.position ?? 'Nhân sự',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Switch Role Fast Button (Hỗ trợ chấm điểm đồ án)
              PopupMenuButton<int>(
                tooltip: 'Chuyển đổi người dùng / Vai trò',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.swap_horiz, color: AppColors.primary, size: 20),
                ),
                onSelected: (int selectedUserId) {
                  auth.switchUser(selectedUserId);
                },
                itemBuilder: (context) {
                  return auth.availableUsers.map((u) {
                    final isCurrent = u.id == user?.id;
                    return PopupMenuItem<int>(
                      value: u.id,
                      child: Row(
                        children: [
                          Icon(
                            u.isManager ? Icons.security : Icons.person_outline,
                            size: 18,
                            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${u.fullName} (${u.isManager ? "Sếp" : "NV"})',
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                                color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            const Icon(Icons.check, size: 16, color: AppColors.primary),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),

              ...?actions,
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
