import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/address.dart';

class AddressService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

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
}
