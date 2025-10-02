import '../../domain/entities/user.dart';

class InMemoryUserService {
  final Map<String, User> _users = {};

  Future<void> addUser(User user, String email, String password) async {
    _users[user.id] = user;
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    return _users.map((key, user) => MapEntry(key, user.toJson()));
  }

  Future<void> deleteUser(String userId) async {
    _users.remove(userId);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    if (_users.containsKey(userId)) {
      final user = _users[userId]!;
      _users[userId] = user.copyWith(
        name: data['name'] ?? user.name,
        lastname: data['lastname'] ?? user.lastname,
        birthdate: data['birthdate'] ?? user.birthdate,
        addresses: data['addresses'] ?? user.addresses,
      );
    }
  }
}
