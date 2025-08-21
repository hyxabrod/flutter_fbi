import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex06_concurrent_events/concurrent_feature.dart';
import 'package:flutter_fbi_example/examples/ex06_concurrent_events/concurrent_entities.dart';

void main() {
  testWidgets('ConcurrentFeature emits slow and fast side effects', (tester) async {
    featureTest<ConcurrentEvent, ConcurrentState, ConcurrentFx>(
      'concurrent events',
      build: () => ConcurrentFeature(),
      act: (f) async {
        f.add(SlowIncEvent());
        f.add(FastPingEvent());
      },
      expect: () => [
        const ConcurrentState(1),
      ],
      expectSideEffects: () => [
        ConcurrentFx('fast'),
        ConcurrentFx('slow-inc-done'),
      ],
      wait: const Duration(seconds: 2),
    );
  });
}
