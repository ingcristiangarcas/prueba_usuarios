import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../infrastructure/firebase/user_repository.dart';
import '../../../domain/entities/user.dart';
import 'package:uuid/uuid.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userId = await _repo.login(event.email.trim(), event.password.trim());
        if (userId != null) {
          emit(AuthSuccess(userId));
        } else {
          emit(AuthFailure("Usuario o contraseña incorrectos"));
        }
      } catch (e) {
        emit(AuthFailure("Error al iniciar sesión: $e"));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final id = const Uuid().v4();
        final user = User(
          id: id,
          name: event.name.trim(),
          lastname: event.lastname.trim(),
          birthdate: event.birthdate,
          addresses: const [],
        );
        await _repo.registerUser(user, event.email.trim(), event.password.trim());
        emit(AuthSuccess(id));
      } catch (e) {
        emit(AuthFailure("Error al registrar usuario: $e"));
      }
    });
  }
}
