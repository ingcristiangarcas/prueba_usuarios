abstract class AddressState {}
class AddressInitial extends AddressState {}
class AddressLoading extends AddressState {}
class AddressSuccess extends AddressState {}
class AddressFailure extends AddressState {
  final String message;
  AddressFailure(this.message);
}
class AddressError extends AddressState {
  final String message;
  AddressError(this.message);
}