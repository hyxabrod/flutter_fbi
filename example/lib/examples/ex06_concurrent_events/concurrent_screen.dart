import 'package:flutter/material.dart';
import 'package:flutter_fbi_example/examples/ex06_concurrent_events/concurrent_binder.dart';

class ConcurrentScreen extends StatefulWidget {
  const ConcurrentScreen({super.key});
  @override
  State<ConcurrentScreen> createState() => _ConcurrentScreenState();
}

class _ConcurrentScreenState extends State<ConcurrentScreen> {
  late ConcurrentBinder binder;

  @override
  void initState() {
    super.initState();
    binder = ConcurrentBinder(context: context);
  }

  @override
  void dispose() {
    binder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Concurrent Events Example')),
      body: Center(
        child: binder.bindState((context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Value: ${state.value}', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: binder.slowInc,
                    child: const Text('Slow increment'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: binder.fastPing,
                    child: const Text('Fast ping (sync: false)'),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    'Press Fast ping right after Slow increment — the SnackBar will appear before the increment, then the value will update.'),
              )
            ],
          );
        }),
      ),
    );
  }
}
