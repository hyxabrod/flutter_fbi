import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/dashboard_binder.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/features/settings_feature.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/features/user_feature.dart';

/// Example demonstrating MultiFeatureBinder with [shouldWaitForAllFeatures] = false
/// When false: UI updates immediately when any feature emits a new state
/// When true: UI would wait for all features before updating
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final binder = DashboardBinder(
        context: context, features: [SettingsFeature(), UserFeature()]);
    return _DashboardWidget(binder: binder);
  }
}

class _DashboardWidget extends BoundWidget<DashboardBinder> {
  const _DashboardWidget({required DashboardBinder binder})
      : super(binder: binder);

  @override
  Widget builder(BuildContext context, DashboardBinder binder) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Feature Example'),
      ),
      body: binder.bindState((context, state) {
        if (state.isLoading &&
            (state.userName == 'Unknown' || state.userEmail == 'No email')) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard (Multi-Feature)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'This example demonstrates MultiFeatureBinder with shouldWaitForAllFeatures = false.\n'
                'The UI updates as soon as any feature emits a new state, without waiting for all features.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // User Profile Section (UserFeature)
              const Text(
                'User Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(state.userName),
                        subtitle: Text(state.userEmail),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Change Name',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: binder.updateUserName,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings Section (SettingsFeature)
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: Text(state.darkMode ? 'Enabled' : 'Disabled'),
                        value: state.darkMode,
                        onChanged: (_) => binder.toggleDarkMode(),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Notifications'),
                        subtitle: Text(state.notificationsEnabled
                            ? 'Enabled'
                            : 'Disabled'),
                        value: state.notificationsEnabled,
                        onChanged: (_) => binder.toggleNotifications(),
                      ),
                    ],
                  ),
                ),
              ),

              if (state.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],

              const SizedBox(height: 48),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'MultiFeatureBinder',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This example demonstrates how to combine multiple features '
                          'into a single UI view. The DashboardBinder merges states from '
                          'UserFeature and SettingsFeature and handles side effects from both.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
