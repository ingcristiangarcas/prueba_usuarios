import '../../../domain/entities/address.dart';

abstract class AddressEvent {}
class AddAddress extends AddressEvent {
  final String userId;
  final Address address;
  AddAddress(this.userId, this.address);
}
class UpdateAddress extends AddressEvent {
  final String userId;
  final String addressId;
  final Map<String, dynamic> data;
  UpdateAddress(this.userId, this.addressId, this.data);
}
class DeleteAddress extends AddressEvent {
  final String userId;
  final String addressId;
  DeleteAddress(this.userId, this.addressId);
}
