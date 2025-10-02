import 'package:freezed_annotation/freezed_annotation.dart';
import 'address.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String lastname,
    required String birthdate, // podemos manejarlo como String "yyyy-MM-dd"
    @Default([]) List<Address> addresses,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
