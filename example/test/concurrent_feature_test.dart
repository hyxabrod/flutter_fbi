import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi/flutter_fbi.dart' show featureTest;
import 'package:flutter_fbi_example/examples/ex06_concurrent_events/concurrent_feature.dart';
import 'package:flutter_fbi_example/examples/ex06_concurrent_events/concurrent_entities.dart';

void main() {
  featureTest<ConcurrentEvent, ConcurrentState, ConcurrentSideEffect>(
    'ConcurrentFeature fast ping side effect',
    build: () => ConcurrentFeature(),
    act: (feature) => feature.add(FastPingEvent()),
    expect: () => <Object?>[],
  );

  featureTest<ConcurrentEvent, ConcurrentState, ConcurrentSideEffect>(
    'ConcurrentFeature: fast (sync:false) is processed while slow inc is running - side effects order',
    build: () => ConcurrentFeature(),
    act: (feature) {
      feature.add(SlowIncEvent());
      feature.add(FastPingEvent(), sync: false);
    },
    expectSideEffects: () => [
      isA<ConcurrentSideEffect>().having((fx) => fx.msg, 'msg', 'fast'),
      isA<ConcurrentSideEffect>().having((fx) => fx.msg, 'msg', 'slow-inc-done'),
    ],
  );

  featureTest<ConcurrentEvent, ConcurrentState, ConcurrentSideEffect>(
    'ConcurrentFeature: fast (sync:false) with slow inc results in incremented state',
    build: () => ConcurrentFeature(),
    act: (feature) {
      feature.add(SlowIncEvent());
      feature.add(FastPingEvent(), sync: false);
    },
    expect: () => [isA<ConcurrentState>().having((s) => s.value, 'value', 1)],
  );

  featureTest<ConcurrentEvent, ConcurrentState, ConcurrentSideEffect>(
    'ConcurrentFeature slow inc emits state',
    build: () => ConcurrentFeature(),
    act: (feature) => feature.add(SlowIncEvent()),
    expect: () => [isA<ConcurrentState>().having((s) => s.value, 'value', 1)],
  );

  featureTest<ConcurrentEvent, ConcurrentState, ConcurrentSideEffect>(
    'ConcurrentFeature slow inc - side effects',
    build: () => ConcurrentFeature(),
    act: (feature) => feature.add(SlowIncEvent()),
    expectSideEffects: () => [isA<ConcurrentSideEffect>().having((fx) => fx.msg, 'msg', 'slow-inc-done')],
  );
}
