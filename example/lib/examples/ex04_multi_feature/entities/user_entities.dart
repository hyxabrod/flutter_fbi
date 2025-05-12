import 'package:flutter_fbi/flutter_fbi.dart';

// Events
abstract class UserEvent extends UiEvent {}

class LoadUserEvent extends UserEvent {}

class UpdateUserNameEvent extends UserEvent {
  final String name;
  UpdateUserNameEvent(this.name);
}

// State
class UserState extends FeatureState {
  final bool isLoading;
  final String? name;
  final String? email;
  final String? error;

  UserState({
    this.isLoading = false,
    this.name,
    this.email,
    this.error,
  });

  UserState copyWith({
    bool? isLoading,
    String? name,
    String? email,
    String? error,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      email: email ?? this.email,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, name, email, error];
}

// Side Effect
abstract class UserSideEffect extends SideEffect {}

class UserUpdatedEffect extends UserSideEffect {
  final String message;
  UserUpdatedEffect(this.message);
}
