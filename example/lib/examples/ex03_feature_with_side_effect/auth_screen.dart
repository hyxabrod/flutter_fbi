import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_binder.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_entities.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final binder = AuthBinder(context: context);
    return _AuthWidget(binder: binder);
  }
}

class _AuthWidget extends BoundWidget<AuthBinder> {
  const _AuthWidget({required AuthBinder binder}) : super(binder: binder);

  @override
  Widget builder(BuildContext context, AuthBinder binder) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Side Effects Example'),
      ),
      body: binder.bindState((context, state) {
        return state.isLoggedIn
            ? _HomeScreen(binder: binder, state: state)
            : _LoginScreen(binder: binder, state: state);
      }),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  final AuthBinder binder;
  final AuthUiState state;

  const _LoginScreen({required this.binder, required this.state});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login Form (with Side Effects)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                helperText: 'Hint: user/password',
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isLoading ? null : () => binder.login(usernameController.text, passwordController.text),
              child: state.isLoading ? const CircularProgressIndicator() : const Text('Login'),
            ),
            const SizedBox(height: 48),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Feature with Side Effects',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This example demonstrates how to handle side effects '
                        'such as toast messages and navigation requests. '
                        'Side effects are one-time events that should not be part of the state.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  final AuthBinder binder;
  final AuthUiState state;

  const _HomeScreen({required this.binder, required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 72,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome, ${state.username}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'You are logged in successfully.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: binder.logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
