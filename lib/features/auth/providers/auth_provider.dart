import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
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
      _availableUsers = await DatabaseHelper.instance.getAllUsers();
      // Default to Uyên (Employee) for employee demo, or Duy Ngọc for Manager demo
      if (_availableUsers.isNotEmpty) {
        _currentUser = _availableUsers.firstWhere(
          (u) => u.fullName == 'Uyên',
          orElse: () => _availableUsers.first,
        );
      }
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

    final user = await DatabaseHelper.instance.getUserById(userId);
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
