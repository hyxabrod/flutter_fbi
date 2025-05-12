import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_entities.dart';

class CounterFeature extends Feature<CounterEvent, CounterState, SideEffect> {
  CounterFeature() : super(initialState: CounterState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(CounterEvent event) {
    if (event is IncrementEvent) {
      _increment();
    } else if (event is DecrementEvent) {
      _decrement();
    } else if (event is ResetEvent) {
      _reset();
    }
  }

  void _increment() {
    emitState(state.copyWith(count: state.count + 1));
  }

  void _decrement() {
    if (state.count > 0) {
      emitState(state.copyWith(count: state.count - 1));
    }
  }

  void _reset() {
    emitState(CounterState());
  }
}
