import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex02_feature_binder_basic/counter_entities.dart';

class CounterFeature extends Feature<CounterEvent, CounterState, SideEffect> {
  CounterFeature() : super(initialState: const CounterState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(CounterEvent event) {
    switch (event) {
      case IncrementEvent():
        _increment();
      case DecrementEvent():
        _decrement();
      case ResetEvent():
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
    emitState(const CounterState());
  }
}
