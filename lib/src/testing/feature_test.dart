// A lightweight testing utility inspired by bloc_test for testing Feature classes.
// Usage:
//   featureTest<CounterEvent, CounterState, CounterSideEffect>(
//     'increments once',
//     build: () => CounterFeature(),
//     act: (feature) => feature.add(IncrementEvent()),
//     expect: () => [CounterState(count: 1)],
//   );

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi/flutter_fbi.dart';

/// A test helper similar to bloc_test but for Feature classes.
///
/// Parameters:
/// - [description]: Test description.
/// - [setUp]: Optional callback run before build.
/// - [build]: Factory to create the feature under test.
/// - [seed]: Optional initial state to emit before actions (emits via emitState).
/// - [act]: Optional actions to perform on the feature (e.g., add events).
/// - [expect]: Expected sequence of Feature states or Matchers (in order).
/// - [expectSideEffects]: Expected sequence of SideEffects or Matchers (in order).
/// - [skip]: Number of states to skip from [stateStream] before asserting. Defaults to 1 (skip initial).
/// - [wait]: Optional delay after [act] to allow async emissions before asserting.
/// - [verify]: Optional additional verifications with access to the feature.
///
/// Note: [seed] emits the provided state on top of the feature's initial state.
void featureTest<E extends UiEvent, S extends FeatureState, F extends SideEffect>(
  String description, {
  FutureOr<void> Function()? setUp,
  required Feature<E, S, F> Function() build,
  S Function()? seed,
  FutureOr<void> Function(Feature<E, S, F> feature)? act,
  Iterable<Object?> Function()? expect,
  Iterable<Object?> Function()? expectSideEffects,
  int skip = 1,
  Duration? wait,
  FutureOr<void> Function(Feature<E, S, F> feature)? verify,
}) {
  test(description, () async {
    // Run optional setup before building the feature
    if (setUp != null) {
      await setUp();
    }

    final feature = build();
    addTearDown(feature.dispose);

    // Seed before we subscribe so we don't need to bump skip manually.
    final seedState = seed?.call();
    if (seedState != null) {
      feature.emitState(seedState);
    }

    // Build expectations using expectLater just like bloc_test does.
    Future<void>? statesFuture;
    if (expect != null) {
      final expectedStates = expect();
      statesFuture = expectLater(
        feature.stateStream.skip(skip),
        emitsInOrder(expectedStates),
      );
    }

    Future<void>? sideEffectsFuture;
    if (expectSideEffects != null) {
      final expectedFx = expectSideEffects();
      sideEffectsFuture = expectLater(
        feature.sideEffect.skip(0),
        emitsInOrder(expectedFx),
      );
    }

    // Perform actions
    if (act != null) {
      await act(feature);
    }

    if (wait != null) {
      await Future<void>.delayed(wait);
    }

    // Await expectations
    if (statesFuture != null) await statesFuture;
    if (sideEffectsFuture != null) await sideEffectsFuture;

    if (verify != null) {
      await verify(feature);
    }
  });
}
