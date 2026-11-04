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
      // Giảng viên & người dùng có thể thấy nút Google Sign-in và 3 tài khoản demo
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

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    // Giả lập hoặc đăng nhập Google Account:
    await Future.delayed(const Duration(milliseconds: 600));
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
