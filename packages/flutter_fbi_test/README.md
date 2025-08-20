# flutter_fbi_test

Testing helpers for the `flutter_fbi` package. Provides `featureTest`, a small helper
for unit-testing `Feature` classes.

Usage:

```dart
import 'package:flutter_fbi_test/flutter_fbi_test.dart';

featureTest<CounterEvent, CounterState, CounterSideEffect>(
  'increments once',
  build: () => CounterFeature(),
  act: (feature) => feature.add(IncrementEvent()),
  expect: () => [CounterState(count: 1)],
);
```
