import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/user.dart';

class UserRepository {
  final _db = FirebaseDatabase.instance.ref();

  Future<void> createUser(User user) async {
    await _db.child("users/${user.id}").set(user.toJson());
  }

  Stream<User?> getUser(String id) {
    return _db.child("users/$id").onValue.map((event) {
      if (event.snapshot.value != null) {
        return User.fromJson(Map<String, dynamic>.from(event.snapshot.value as Map));
      }
      return null;
    });
  }
}
