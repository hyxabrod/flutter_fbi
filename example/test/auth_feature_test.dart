import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi/flutter_fbi.dart' show featureTest;
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_feature.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_entities.dart';

void main() {
  featureTest<AuthEvent, AuthState, AuthSideEffect>(
    'AuthFeature login success emits loading and logged in states and side effects',
    build: () => AuthFeature(),
    act: (feature) => feature.add(LoginEvent(username: 'user', password: 'password')),
    expect: () => [
      isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
      isA<AuthState>().having((s) => s.isLoggedIn, 'isLoggedIn', true),
    ],
  );

  featureTest<AuthEvent, AuthState, AuthSideEffect>(
    'AuthFeature login success - side effects',
    build: () => AuthFeature(),
    act: (feature) => feature.add(LoginEvent(username: 'user', password: 'password')),
    expectSideEffects: () => [
      isA<ShowToastEffect>().having((e) => e.message, 'message', contains('Welcome')),
      isA<NavigateToHomeEffect>(),
    ],
  );

  featureTest<AuthEvent, AuthState, AuthSideEffect>(
    'AuthFeature login failure (empty) - states',
    build: () => AuthFeature(),
    act: (feature) => feature.add(LoginEvent(username: '', password: '')),
    expect: () => [
      isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
      isA<AuthState>().having((s) => s.error, 'error', 'Username and password cannot be empty'),
    ],
  );

  featureTest<AuthEvent, AuthState, AuthSideEffect>(
    'AuthFeature login failure (empty) - side effects',
    build: () => AuthFeature(),
    act: (feature) => feature.add(LoginEvent(username: '', password: '')),
    expectSideEffects: () => [isA<ShowToastEffect>().having((e) => e.message, 'message', 'Login failed')],
  );

  featureTest<AuthEvent, AuthState, AuthSideEffect>(
    'AuthFeature logout - states',
    build: () => AuthFeature(),
    seed: () => const AuthState(isLoggedIn: true, isLoading: false, username: 'user', error: null),
    act: (feature) => feature.add(LogoutEvent()),
    expect: () => [isA<AuthState>().having((s) => s.isLoggedIn, 'loggedIn', false)],
  );

  featureTest<AuthEvent, AuthState, AuthSideEffect>(
    'AuthFeature logout - side effects',
    build: () => AuthFeature(),
    seed: () => const AuthState(isLoggedIn: true, isLoading: false, username: 'user', error: null),
    act: (feature) => feature.add(LogoutEvent()),
    expectSideEffects: () => [
      isA<ShowToastEffect>().having((e) => e.message, 'message', 'Logged out successfully'),
      isA<NavigateToLoginEffect>(),
    ],
  );
}
