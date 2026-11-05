import 'package:flutter/foundation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  List<User> _availableUsers = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<User> get availableUsers => _availableUsers;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isManager => _currentUser?.isManager ?? false;

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _availableUsers = await AppDatabase.instance.getAllUsers();
      // Giữ currentUser = null lúc khởi động ban đầu để hiển thị màn hình LoginScreen
      _currentUser = null;
    } catch (e) {
      debugPrint('Auth init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    final user = await AppDatabase.instance.getUserById(userId);
    if (user != null) {
      _currentUser = user;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Đăng nhập bằng tài khoản Gmail / Email cụ thể
  Future<bool> loginWithEmail(String email, {String preferredRole = 'EMPLOYEE'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cleanEmail = email.trim().toLowerCase();
      // 1. Tìm chính xác trong DB theo email
      var user = await AppDatabase.instance.getUserByEmail(cleanEmail);

      // 2. Nếu không thấy, tìm đối sánh thông minh theo tiền tố email
      if (user == null) {
        final prefix = cleanEmail.split('@').first;
        for (final u in _availableUsers) {
          final uEmail = u.email.toLowerCase();
          final uName = u.fullName.toLowerCase();
          if (uEmail == cleanEmail ||
              uEmail.startsWith(prefix) ||
              (prefix.contains('ngoc') && uName.contains('ngọc')) ||
              (prefix.contains('uyen') && uName.contains('uyên')) ||
              (prefix.contains('nam') && uName.contains('nam')) ||
              (prefix.contains('thao') && uName.contains('thảo'))) {
            user = u;
            break;
          }
        }
      }

      // 3. Nếu là tài khoản hoàn toàn mới chưa có trong hệ thống, tự động cấp tài khoản trải nghiệm
      if (user == null) {
        final prefix = cleanEmail.split('@').first;
        final displayName = prefix.isNotEmpty
            ? '${prefix[0].toUpperCase()}${prefix.substring(1)}'
            : 'Người dùng Google';

        user = User(
          id: 99,
          email: cleanEmail,
          fullName: displayName,
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          role: preferredRole,
          departmentId: 1,
          position: preferredRole == 'MANAGER' ? 'Trưởng phòng Kỹ thuật' : 'Chuyên viên Nhân sự',
          startDate: '2025-01-01',
          annualLeaveQuota: 12,
        );
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login with email error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    // Giả lập đăng nhập nhanh qua Google Account
    await Future.delayed(const Duration(milliseconds: 500));
    if (_availableUsers.isNotEmpty) {
      _currentUser = _availableUsers.firstWhere(
        (u) => u.role == 'EMPLOYEE',
        orElse: () => _availableUsers.first,
      );
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
