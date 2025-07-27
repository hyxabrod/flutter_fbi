import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_entities.dart';

class AuthFeature extends Feature<AuthEvent, AuthState, AuthSideEffect> {
  AuthFeature() : super(initialState: AuthState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(AuthEvent event) async {
    if (event is LoginEvent) {
      await _login(event.username, event.password);
    } else if (event is LogoutEvent) {
      _logout();
    }
  }

  Future<void> _login(String username, String password) async {
    emitState(state.copyWith(isLoading: true, error: null));

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Simple validation
    if (username.isEmpty || password.isEmpty) {
      emitState(state.copyWith(
        isLoading: false,
        error: 'Username and password cannot be empty',
      ));
      emitSideEffect(ShowToastEffect('Login failed'));
      return;
    }

    // Simple credential check (demo only)
    if (username == 'user' && password == 'password') {
      emitState(state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        username: username,
        error: null,
      ));
      emitSideEffect(ShowToastEffect('Welcome, $username!'));
      emitSideEffect(NavigateToHomeEffect());
    } else {
      emitState(state.copyWith(
        isLoading: false,
        error: 'Invalid credentials',
      ));
      emitSideEffect(ShowToastEffect('Invalid username or password'));
    }
  }

  void _logout() {
    emitState(AuthState());
    emitSideEffect(ShowToastEffect('Logged out successfully'));
    emitSideEffect(NavigateToLoginEffect());
  }
}
