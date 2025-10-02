import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';

class UserRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<String?> login(String email, String password) async {
    final snapshot = await _db.child("users").get();
    if (!snapshot.exists) return null;
    final users = Map<String, dynamic>.from(snapshot.value as Map);
    for (var entry in users.entries) {
      final user = Map<String, dynamic>.from(entry.value);
      if (user["email"] == email && user["password"] == password) {
        return entry.key;
      }
    }
    return null;
  }

  Future<String> registerUser(User user, String email, String password) async {
    final id = user.id;
    await _db.child("users/$id").set({
      ...user.toJson(),
      "email": email,
      "password": password,
    });
    return id;
  }

  Future<void> addAddress(String userId, Address address) async {
  final id = const Uuid().v4(); // genera un id único
  await _db.child("users/$userId/addresses/$id").set(address.toJson());
}

  Future<void> updateAddress(String userId, String addressId, Map<String, dynamic> data) async {
    await _db.child("users/$userId/addresses/$addressId").update(data);
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    await _db.child("users/$userId/addresses/$addressId").remove();
  }

  Future<void> deleteUser(String userId) async {
    await _db.child("users/$userId").remove();
  }
}
