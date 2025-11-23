import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex01_simple_binder/simple_counter_state.dart';

class SimpleCounterBinder extends SimpleBinder<SimpleCounterState> {
  SimpleCounterBinder({required super.context})
      : super(
          uiStatePreprocessor: () => const SimpleCounterState(),
        );

  void increment() {
    emitUiState(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    emitUiState(state.copyWith(count: state.count - 1));
  }

  void reset() {
    emitUiState(const SimpleCounterState());
  }
}
