import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_entities.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_feature.dart';

class AuthBinder extends FeatureBinder<AuthEvent, AuthState, AuthUiState, AuthSideEffect> {
  AuthBinder({required BuildContext context})
      : super(
          context: context,
          feature: AuthFeature(),
          uiStatePreprocessor: () => const AuthUiState(
            isLoggedIn: false,
            isLoading: false,
          ),
        ) {
    // Setup for side effect handling
    _setupSideEffectHandling();
  }

  void login(String username, String password) {
    feature.add(LoginEvent(username: username, password: password));
  }

  void logout() {
    feature.add(LogoutEvent());
  }

  /// Configures side effect handling within the binder
  void _setupSideEffectHandling() {
    bindSideEffect((effect) {
      switch (effect) {
        case ShowToastEffect():
          _showToast(effect.message);
        case NavigateToHomeEffect():
          // In a real application, navigation would happen here
          // For demo purposes, we just show a dialog
          _showInfoDialog(
            'Home Screen',
            'In a real app, we would navigate to the Home screen.',
          );
        case NavigateToLoginEffect():
          // In a real application, navigation would happen here
          // For demo purposes, we just show a dialog
          _showInfoDialog(
            'Login Screen',
            'In a real app, we would navigate to the Login screen.',
          );
      }
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  AuthUiState uiStateTransformer(AuthState featureState) {
    return AuthUiState(
      isLoggedIn: featureState.isLoggedIn,
      isLoading: featureState.isLoading,
      username: featureState.username,
      error: featureState.error,
    );
  }
}
