import 'package:flutter_bloc/flutter_bloc.dart';
import 'address_event.dart';
import 'address_state.dart';
import '../../../infrastructure/firebase/user_repository.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final UserRepository _repo;

  AddressBloc(this._repo) : super(AddressInitial()) {
    on<AddAddress>((event, emit) async {
      emit(AddressLoading());
      try {
        await _repo.addAddress(event.userId, event.address);
        emit(AddressSuccess());
      } catch (e) {
        emit(AddressFailure("Error al guardar dirección: $e"));
      }
    });

    on<UpdateAddress>((event, emit) async {
      emit(AddressLoading());
      try {
        await _repo.updateAddress(event.userId, event.addressId, event.data);
        emit(AddressSuccess());
      } catch (e) {
        emit(AddressFailure("Error al actualizar dirección: $e"));
      }
    });

    on<DeleteAddress>((event, emit) async {
      emit(AddressLoading());
      try {
        await _repo.deleteAddress(event.userId, event.addressId);
        emit(AddressSuccess());
      } catch (e) {
        emit(AddressFailure("Error al eliminar dirección: $e"));
      }
    });
  }
}
