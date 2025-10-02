abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String name, lastname, email, password;
  final String birthdate;
  RegisterRequested({
    required this.name,
    required this.lastname,
    required this.email,
    required this.password,
    required this.birthdate,
  });
}
