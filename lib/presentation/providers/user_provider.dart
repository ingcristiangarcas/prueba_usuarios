import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../data/services/user_service.dart';


class UserProvider extends ChangeNotifier {
  final dynamic _service;

  Map<String, dynamic> _users = {};
  Map<String, dynamic> get users => _users;

  UserProvider({dynamic service}) : _service = service ?? UserService();

  Future<void> fetchUsers() async {
    _users = await _service.getAllUsers();
    notifyListeners();
  }

  Future<void> addUser(User user, String email, String password) async {
    await _service.addUser(user, email, password);
    await fetchUsers();
  }

  Future<void> deleteUser(String userId) async {
    await _service.deleteUser(userId);
    await fetchUsers();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _service.updateUser(userId, data);
    await fetchUsers();
  }
}
