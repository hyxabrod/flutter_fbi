import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_test/flutter_test.dart';

// A minimal feature used only for testing the helper itself.
class IncEvent extends UiEvent {}

class DecEvent extends UiEvent {}

class ResetEvent extends UiEvent {}

class CounterState extends FeatureState {
  final int value;
  const CounterState(this.value);
  @override
  List<Object?> get props => [value];
}

class PingFx extends SideEffect {
  final String msg;
  PingFx(this.msg);
}

class CounterFeature extends Feature<UiEvent, CounterState, PingFx> {
  CounterFeature() : super(initialState: const CounterState(0)) {
    onEvent((event) {
      if (event is IncEvent) {
        emitState(CounterState(state.value + 1));
        emitSideEffect(PingFx('inc'));
      } else if (event is DecEvent) {
        emitState(CounterState(state.value - 1));
      } else if (event is ResetEvent) {
        emitState(const CounterState(0));
        emitSideEffect(PingFx('reset'));
      }
    });
  }
}

// New events and feature to demonstrate sequential: false
class SlowIncEvent extends UiEvent {}

class FastPingEvent extends UiEvent {}

class ConcurrentCounterFeature extends Feature<UiEvent, CounterState, PingFx> {
  ConcurrentCounterFeature() : super(initialState: const CounterState(0)) {
    onEvent((event) async {
      if (event is SlowIncEvent) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        emitState(CounterState(state.value + 1));
        emitSideEffect(PingFx('slow-inc-done'));
      } else if (event is FastPingEvent) {
        emitSideEffect(PingFx('fast'));
      }
    });
  }
}

void main() {
  featureTest<UiEvent, CounterState, PingFx>(
    'emits states and side effects in order',
    setUp: () async {
      // Optional pre-build setup
    },
    build: () => CounterFeature(),
    act: (f) async {
      f.add(IncEvent());
      f.add(IncEvent());
      f.add(DecEvent());
      f.add(ResetEvent());
    },
    // Skip the initial state (0)
    expect: () => [
      isA<CounterState>().having((s) => s.value, 'value', 1),
      isA<CounterState>().having((s) => s.value, 'value', 2),
      isA<CounterState>().having((s) => s.value, 'value', 1),
      isA<CounterState>().having((s) => s.value, 'value', 0),
    ],
    expectSideEffects: () => [
      isA<PingFx>().having((fx) => fx.msg, 'msg', 'inc'),
      isA<PingFx>().having((fx) => fx.msg, 'msg', 'inc'),
      isA<PingFx>().having((fx) => fx.msg, 'msg', 'reset'),
    ],
  );

  // Demonstrates that an event added with sequential: false is handled
  // concurrently and can complete before a queued slow event.
  featureTest<UiEvent, CounterState, PingFx>(
    'handles concurrent event without waiting for slow queued event',
    build: () => ConcurrentCounterFeature(),
    act: (f) async {
      f.add(SlowIncEvent()); // goes into sequential queue
      f.add(FastPingEvent(), sync: false); // dispatched concurrently
    },
    expect: () => [
      isA<CounterState>().having((s) => s.value, 'value', 1),
    ],
    expectSideEffects: () => [
      isA<PingFx>().having((fx) => fx.msg, 'msg', 'fast'),
      isA<PingFx>().having((fx) => fx.msg, 'msg', 'slow-inc-done'),
    ],
  );
}
