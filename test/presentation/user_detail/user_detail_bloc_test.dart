import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usuarios/domain/entities/user.dart';
import 'package:usuarios/data/repositories/user_repository.dart';
import 'package:usuarios/presentation/screens/user_detail/user_detail_screen.dart';

// Mock del repositorio
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late UserDetailBloc bloc;

  final testUser = UserEntity(
    id: '1',
    nombre: 'Juan',
    email: 'juan@rcnradio.com',
    direccion: 'Calle 123',
  );

  setUp(() {
    mockUserRepository = MockUserRepository();
    bloc = UserDetailBloc(userRepository: mockUserRepository);
  });

  blocTest<UserDetailBloc, UserDetailState>(
    'Emite [loading, success] cuando guardar es exitoso',
    build: () {
      when(() => mockUserRepository.saveUser(any()))
          .thenAnswer((_) async => Future.value());
      return bloc;
    },
    act: (bloc) => bloc.add(SaveUserEvent(testUser)),
    expect: () => [
      UserDetailLoading(),
      UserDetailSuccess(),
    ],
  );

  blocTest<UserDetailBloc, UserDetailState>(
    'Emite [loading, error] cuando guardar falla',
    build: () {
      when(() => mockUserRepository.saveUser(any()))
          .thenThrow(Exception('Error Firebase'));
      return bloc;
    },
    act: (bloc) => bloc.add(SaveUserEvent(testUser)),
    expect: () => [
      UserDetailLoading(),
      isA<UserDetailError>(),
    ],
  );
}
