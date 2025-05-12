import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_binder.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CounterWidget(
      binder: CounterBinder(context: context),
    );
  }
}

class _CounterWidget extends BoundWidget<CounterBinder> {
  const _CounterWidget({required CounterBinder binder}) : super(binder: binder);

  @override
  Widget builder(BuildContext context, CounterBinder binder) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Binder Example'),
      ),
      body: binder.bindState((context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Counter with Feature:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              Text(
                state.countText,
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: state.canDecrement ? binder.decrement : null,
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
                          'FeatureBinder',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This example uses a BaseFeature for business logic and a FeatureBinder '
                          'to transform the feature state for the UI. Notice how the binder adds '
                          'UI-specific properties like "canDecrement" and "countText".',
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
