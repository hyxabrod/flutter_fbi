import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_entities.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_feature.dart';

class CounterBinder extends FeatureBinder<CounterEvent, CounterState, CounterUiState, SideEffect> {
  CounterBinder({required super.context})
      : super(
          feature: CounterFeature(),
          uiStatePreprocessor: () => const CounterUiState(
            count: 0,
            countText: '0',
            canDecrement: false,
          ),
        );

  void increment() {
    feature.add(IncrementEvent());
  }

  void decrement() {
    feature.add(DecrementEvent());
  }

  void reset() {
    feature.add(ResetEvent());
  }

  @override
  CounterUiState uiStateTransformer(CounterState featureState) {
    return CounterUiState(
      count: featureState.count,
      countText: '${featureState.count}',
      canDecrement: featureState.count > 0,
    );
  }
}
