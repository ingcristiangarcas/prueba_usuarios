import 'package:flutter_test/flutter_test.dart';
import 'package:usuarios/data/repositories/in_memory_user_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:usuarios/domain/entities/user.dart';
import 'package:usuarios/presentation/providers/user_provider.dart';


void main() {
  late UserProvider provider;
  late String userId;
  late User testUser;

  setUp(() {
    provider = UserProvider(service: InMemoryUserService());
    userId = const Uuid().v4();
    testUser = User(
      id: userId,
      name: 'Cristian',
      lastname: 'Garcia',
      birthdate: '1990-01-01',
      addresses: [],
    );
  });

  test('Agregar usuario y cargar usuarios', () async {
    await provider.addUser(testUser, 'test@email.com', 'Password1@');
    expect(provider.users.containsKey(userId), true);
    expect(provider.users[userId]['name'], 'Cristian');
  });

  test('Actualizar usuario', () async {
    await provider.addUser(testUser, 'test@email.com', 'Password1@');

    await provider.updateUser(userId, {'name': 'Benjamín'});
    expect(provider.users[userId]['name'], 'Benjamín');
  });

  test('Eliminar usuario', () async {
    await provider.addUser(testUser, 'test@email.com', 'Password1@');

    await provider.deleteUser(userId);
    expect(provider.users.containsKey(userId), false);
  });
}
