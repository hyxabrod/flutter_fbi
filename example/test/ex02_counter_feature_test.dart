import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_feature.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_entities.dart';

void main() {
  testWidgets('CounterFeature emits incremented states', (tester) async {
    featureTest<CounterEvent, CounterState, dynamic>(
      'increments twice',
      build: () => CounterFeature(),
      act: (f) {
        f.add(IncrementEvent());
        f.add(IncrementEvent());
      },
      expect: () => [
        const CounterState(count: 1),
        const CounterState(count: 2),
      ],
    );
  });
}
