# flutter_fbi_test

Testing helpers for the `flutter_fbi` package. Provides a small, focused
`featureTest` helper to simplify unit-testing `Feature` classes from
`flutter_fbi`.

Features

- Lightweight test helper for `Feature` classes.
- Small surface area — depends only on `flutter_fbi` and `flutter_test`.

Installation

Add to your `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_fbi_test: ^0.1.4
  flutter_test:
    sdk: flutter
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

Guidance

- Keep this package in `dev_dependencies` — it is intended for tests only.
- Update the `flutter_fbi` constraint to match the published compatible
  version range when upgrading the core package.

License

This package is licensed under the Apache License 2.0. See the `LICENSE` file
for details.

