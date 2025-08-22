import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex01_simple_binder/simple_counter_binder.dart';

class SimpleCounterScreen extends StatelessWidget {
  const SimpleCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SimpleCounterWidget(
      binder: SimpleCounterBinder(context: context),
    );
  }
}

class _SimpleCounterWidget extends SimpleBoundWidget<SimpleCounterBinder> {
  const _SimpleCounterWidget({required super.binder});

  @override
  Widget builder(BuildContext context, SimpleCounterBinder binder) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Binder Example'),
      ),
      body: binder.bindState((context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Simple Counter (No Feature):',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              Text(
                '${state.count}',
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: binder.decrement,
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: binder.reset,
                    child: const Icon(Icons.refresh),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: binder.increment,
                    child: const Icon(Icons.add),
                  ),
                ],
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
                          'SimpleBinder',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This example uses SimpleBinder, which manages UI state without a Feature class. '
                          'Ideal for simple UI components or forms that don\'t need complex business logic.',
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
