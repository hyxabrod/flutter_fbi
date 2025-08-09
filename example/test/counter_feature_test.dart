import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_entities.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_feature.dart';

void main() {
  featureTest<CounterEvent, CounterState, SideEffect>(
    'counter increments and resets',
    build: () => CounterFeature(),
    act: (feature) async {
      feature.add(IncrementEvent());
      feature.add(IncrementEvent());
      feature.add(ResetEvent());
    },
    expect: () => [
      CounterState(count: 1),
      CounterState(count: 2),
      CounterState(count: 0),
    ],
  );
}
