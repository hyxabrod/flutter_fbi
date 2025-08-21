import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_feature.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_entities.dart';

void main() {
  testWidgets('AuthFeature successful login emits states and side effects', (tester) async {
    featureTest<AuthEvent, AuthState, AuthSideEffect>(
      'login success',
      build: () => AuthFeature(),
      act: (f) => f.add(LoginEvent(username: 'user', password: 'password')),
      expect: () => [
        const AuthState(isLoading: true),
        AuthState(isLoggedIn: true, isLoading: false, username: 'user'),
      ],
      expectSideEffects: () => [
        ShowToastEffect('Welcome, user!'),
        NavigateToHomeEffect(),
      ],
    );
  });
}
