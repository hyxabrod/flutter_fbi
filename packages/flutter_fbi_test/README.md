# flutter_fbi_test

Testing helpers for the `flutter_fbi` package. Provides a small, focused
`featureTest` helper to simplify unit-testing `Feature` classes from
`flutter_fbi`.

Features

- Lightweight test helper for `Feature` classes
- Separate assertions for states and side-effects
- Minimal surface area — depends on `flutter_fbi` and `flutter_test`

Installation

Add to your `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_fbi_test: ^0.1.5
  flutter_test:
    sdk: flutter
```

API

```dart
@isTest
void featureTest<E extends UiEvent, S extends FeatureState, F extends SideEffect>(
  String description, {
  FutureOr<void> Function()? setUp,
  required Feature<E, S, F> Function() build,
  S Function()? seed,
  FutureOr<void> Function(Feature<E, S, F> feature)? act,
  Iterable<Object?> Function()? expect,
  Iterable<Object?> Function()? expectSideEffects,
  int skip = 1, // skip initial state by default
  Duration? wait,
  FutureOr<void> Function(Feature<E, S, F> feature)? verify,
})
```

Basic usage

```dart
import 'package:flutter_fbi_test/flutter_fbi_test.dart';

featureTest<CounterEvent, CounterState, CounterSideEffect>(
  'increments once',
  build: () => CounterFeature(),
  act: (feature) => feature.add(IncrementEvent()),
  expect: () => [CounterState(count: 1)],
);
```

With side-effects and wait

```dart
featureTest<AuthEvent, AuthState, AuthSideEffect>(
  'login success shows toast',
  build: () => AuthFeature(),
  act: (f) => f.add(LoginRequested('u', 'p')),
  expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
  expectSideEffects: () => [isA<ShowToastEffect>()],
  wait: const Duration(milliseconds: 50),
);
```

Guidance

- Keep this package in `dev_dependencies` — it is intended for tests only
- Keep `skip` at default `1` to skip the initial seeded state
- Use `wait` if your feature emits asynchronously after `act`

License

Apache License 2.0 — see `LICENSE` for details
