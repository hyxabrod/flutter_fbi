import 'package:flutter_fbi/flutter_fbi.dart';

// Events
abstract class AuthEvent extends UiEvent {}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent({required this.username, required this.password});
}

class LogoutEvent extends AuthEvent {}

// State
class AuthState extends FeatureState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? username;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.username,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? username,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoggedIn, isLoading, username, error];
}

// UI State
class AuthUiState extends BinderState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? username;
  final String? error;

  const AuthUiState({
    required this.isLoggedIn,
    required this.isLoading,
    this.username,
    this.error,
  });

  @override
  List<Object?> get props => [isLoggedIn, isLoading, username, error];
}

// Side Effects
abstract class AuthSideEffect extends SideEffect {}

class ShowToastEffect extends AuthSideEffect {
  final String message;
  ShowToastEffect(this.message);
}

class NavigateToHomeEffect extends AuthSideEffect {}

class NavigateToLoginEffect extends AuthSideEffect {}
