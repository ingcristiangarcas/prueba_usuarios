import 'package:firebase_database/firebase_database.dart';
import 'package:usuarios/domain/entities/user.dart';


class UserService {
  final DatabaseReference _db;

  // Constructor normal
  UserService() : _db = FirebaseDatabase.instance.ref();

  // Constructor de prueba para inyectar un mock
  UserService.test(this._db);

  Future<void> addUser(User user, String email, String password) async {
    await _db.child("users/${user.id}").set({
      ...user.toJson(),
      "email": email,
      "password": password,
    });
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    final snapshot = await _db.child("users").get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {};
  }

  Future<void> deleteUser(String userId) async {
    await _db.child("users/$userId").remove();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db.child("users/$userId").update(data);
  }
}
