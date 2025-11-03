import 'package:flutter_fbi/flutter_fbi.dart';

class UserProfileState extends BinderState {
  final String name;
  final int age;
  final String email;
  final bool isPremium;

  const UserProfileState({
    this.name = 'John Doe',
    this.age = 25,
    this.email = 'john@example.com',
    this.isPremium = false,
  });

  UserProfileState copyWith({
    String? name,
    int? age,
    String? email,
    bool? isPremium,
  }) {
    return UserProfileState(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  List<Object?> get props => [name, age, email, isPremium];
}
