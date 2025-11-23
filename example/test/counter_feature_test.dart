import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_feature.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_entities.dart';

void main() {
  featureTest<CounterEvent, CounterState, SideEffect>(
    'CounterFeature increments',
    build: () => CounterFeature(),
    act: (f) => f.add(IncrementEvent()),
    expect: () => [isA<CounterState>().having((s) => s.count, 'count', 1)],
  );

  featureTest<CounterEvent, CounterState, SideEffect>(
    'CounterFeature decrements but not below 0',
    build: () => CounterFeature(),
    seed: () => const CounterState(count: 0),
    act: (f) => f.add(DecrementEvent()),
    expect: () => <Object?>[],
  );

  featureTest<CounterEvent, CounterState, SideEffect>(
    'CounterFeature reset',
    build: () => CounterFeature(),
    seed: () => const CounterState(count: 5),
    act: (f) => f.add(ResetEvent()),
    expect: () => [isA<CounterState>().having((s) => s.count, 'count', 0)],
  );
}
