import 'package:flutter/material.dart';
import 'package:flutter_fbi_example/examples/ex01_simple_binder/simple_counter_screen.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_screen.dart';
import 'package:flutter_fbi_example/examples/ex03_feature_with_side_effect/auth_screen.dart';
import 'package:flutter_fbi_example/examples/ex04_multi_feature/dashboard_screen.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/dashboard_with_wait_screen.dart';
import 'package:flutter_fbi_example/examples/ex06_concurrent_events/concurrent_screen.dart';

class ExampleNavigator extends StatelessWidget {
  const ExampleNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter FBI Examples'),
      ),
      body: ListView(
        children: [
          _ExampleTile(
            title: 'Example 1: Simple Binder',
            subtitle: 'Basic UI state management without features',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SimpleCounterScreen()),
            ),
          ),
          _ExampleTile(
            title: 'Example 2: Feature Binder',
            subtitle: 'Single feature with state management',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CounterScreen()),
            ),
          ),
          _ExampleTile(
            title: 'Example 3: Feature with Side Effects',
            subtitle: 'Feature with side effects (e.g., navigation, toasts)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            ),
          ),
          _ExampleTile(
            title: 'Example 4: Do Not Wait For All Features',
            subtitle: 'Multi-Feature with shouldWaitForAllFeatures = false',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
          ),
          _ExampleTile(
            title: 'Example 5: Wait For All Features',
            subtitle: 'Multi-Feature with shouldWaitForAllFeatures = true',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DashboardWithWaitScreen()),
            ),
          ),
          _ExampleTile(
            title: 'Example 6: Concurrent events (sync: false)',
            subtitle: 'Dispatch an event concurrently, bypassing the queue',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConcurrentScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExampleTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
