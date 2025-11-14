<div align="center">
  <img src="https://raw.githubusercontent.com/hyxabrod/flutter_fbi/master/flutter_fbi_icon.svg" alt="Flutter FBI Logo" width="120" height="120">
  
  # Flutter FBI

  **F**eature. **B**inder. **I**nterface.

  [![pub package](https://img.shields.io/pub/v/flutter_fbi.svg)](https://pub.dev/packages/flutter_fbi)
  [![Dart 3 compatible](https://img.shields.io/badge/Dart%203-compatible-blue.svg)](https://dart.dev/guides/language/evolution#dart-3)
  [![Flutter compatible](https://img.shields.io/badge/Flutter-compatible-blue.svg)](https://flutter.dev)
</div>

A state management library that represents features as separate entities, which can be manipulated at the presentation level and updated through the user interface using finite states. Thanks to the fact that third-party visual effects are implemented in an intermediate presentation layer (Binder), the final UI becomes more lightweight.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Components](#components)
  - [Feature Layer](#feature-layer)
  - [Binder Layer](#binder-layer)
  - [Interface Layer](#interface-layer)
- [Examples](#examples)
  - [Feature Binder Example](#feature-binder-example)
  - [Multi-Feature Example](#multi-feature-example)
- [Testing](#testing)
  - [Testing Features](#testing-features)
- [Why Flutter FBI?](#why-flutter-fbi)
- [License](#license)

## Overview

Flutter FBI provides a structured approach to Flutter application development by separating your code into three layers:

1. **Feature** - Manages business logic and state
2. **Binder** - Connects features to UI and transforms state
3. **Interface** - UI components that display data and capture user input

<div align="center">
  <img src="https://raw.githubusercontent.com/hyxabrod/flutter_fbi/master/flutter_fbi_architecture_schema.svg" alt="FBI state managemenet" width="100%">
</div>

<br><br><br>

The architecture follows the **"One Widget → One Binder"** principle, ensuring clean separation and maintainability. Each Flutter widget has its own dedicated binder, which can connect to single features (simple scenarios) or coordinate multiple features (complex scenarios), with reactive data flow powered by Dart streams.

<br><br>

## Installation

```yaml
dependencies:
  flutter_fbi: ^1.5.5
```

## Components

### Feature Layer

Features manage the business logic and state of your application using queue-based event processing for guaranteed ordering.

- **BaseFeature**: Process events sequentially and emit states
- **Feature**: Extends BaseFeature to also handle side effects (one-time events)
- **Event Processing**: Queue-based sequential processing with optional concurrent dispatch

<details>
<summary><span style="color: purple;">Click to expand</span> Feature Layer example</summary>

```dart
// Define events, state, and side effects
abstract class CounterEvent extends UiEvent {}
class IncrementEvent extends CounterEvent {}

class CounterState extends FeatureState {
  final int count;
  const CounterState({this.count = 0});
  
  @override
  List<Object?> get props => [count];
}

// Create a feature
class CounterFeature extends BaseFeature<CounterEvent, CounterState> {
  CounterFeature() : super(initialState: const CounterState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(CounterEvent event) {
    switch (event) {
      case IncrementEvent():
        emitState(CounterState(count: state.count + 1));
    }
  }
  
  // Add events to be processed sequentially (default)
  void increment() => add(IncrementEvent());
  
  // Or add events concurrently (bypasses queue)
  void fastIncrement() => add(IncrementEvent(), sync: false);
}
```

</details>

### Binder Layer

Binders connect features to the UI and transform feature states into UI states.

- **SimpleBinder**: For UI state without a feature
- **FeatureBinder**: Connects a single feature to UI
- **MultiFeatureBinder**: Connects multiple features to UI

All binders provide two methods for binding UI to state:

- **bindState**: Rebuilds the widget when any part of the state changes
- **bindField**: Rebuilds only when a specific field changes (optimized performance)

#### BinderProvider

`BinderProvider` is an Inherited-style provider that exposes a `BasicBinder`
instance to its widget subtree. This library provides two forms:

- `BinderProvider<T>` — a simple way to expose an existing binder instance to
  descendants. Use `BinderProvider.of<T>(context)` or the `context.findBinder<T>()`
  extension to access it.
- `DisposableBinderProvider<T>` — convenience `StatefulWidget` that creates a
  binder via a `create(BuildContext)` callback and automatically calls
  `dispose()` on the binder when the widget is removed from the tree.

The `BinderProvider` implementation used by this package is stateful under the
hood: it stores the current binder instance and updates an internal
`InheritedWidget` when the instance changes. This ensures widgets that depend on
the binder are notified if you swap the binder instance via rebuilding the
provider with a new value.

Usage examples:

<details>
<summary><span style="color: purple;">Click to expand</span> BinderProvider examples</summary>

```dart
// Exposing an existing binder
BinderProvider<MyBinder>(
  binder: myBinder,
  child: MyWidget(),
)

// Letting the provider own the binder lifecycle
DisposableBinderProvider<MyBinder>(
  create: (context) => MyBinder(context: context),
  child: MyWidget(),
)

// Accessing the binder from descendants
final binder = context.findBinder<MyBinder>();
```

</details>

#### When to use DisposableBinderProvider

Use `DisposableBinderProvider` when you want the provider to manage the binder's entire lifecycle. This is ideal for:

- **Route-level binders** that should be created when entering a screen and disposed when leaving
- **Modal dialogs** that need their own isolated state
- **Complex forms** with temporary state that shouldn't persist

<details>
<summary><span style="color: purple;">Click to expand</span> DisposableBinderProvider example</summary>

```dart
// Perfect for route-level state management
class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Binder created when screen opens, disposed when screen closes
    return DisposableBinderProvider<UserProfileBinder>(
      create: (context) => UserProfileBinder(
        context: context,
        userId: userId, // Pass route parameters
        repository: context.read<UserRepository>(),
      ),
      child: const _UserProfileContent(),
    );
  }
}

class _UserProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final binder = context.findBinder<UserProfileBinder>();
    
    return Scaffold(
      body: binder.bindState((context, state) {
        if (state.isLoading) return CircularProgressIndicator();
        return Column(
          children: [
            Text('User: ${state.userName}'),
            ElevatedButton(
              onPressed: binder.refreshProfile,
              child: Text('Refresh'),
            ),
          ],
        );
      }),
    );
  }
}

// Compare with regular BinderProvider (manual lifecycle)
class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserListBinder _binder;

  @override
  void initState() {
    super.initState();
    _binder = UserListBinder(context: context); // Manual creation
  }

  @override
  void dispose() {
    _binder.dispose(); // Manual disposal - easy to forget!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BinderProvider<UserListBinder>(
      binder: _binder,
      child: UserListContent(),
    );
  }
}
```

</details>

#### uiStatePreprocessor

The `uiStatePreprocessor` is a required function that preprocesses the UI state before it gets applied to the widget. This function allows you to:

- **Transform state**: Modify the state before it reaches the UI
- **Add validation**: Ensure state consistency and validity
- **Apply fallback values**: Provide default values for missing or invalid data
- **Combine data**: Merge data from multiple sources into a single UI state

<details>
<summary><span style="color: purple;">Click to expand</span> Binder Layer example</summary>

```dart
// Example of uiStatePreprocessor usage
uiStatePreprocessor: () {
  // Apply fallback values and validation
  return CounterUiState(
    count: state.count.clamp(0, 100), // Ensure count is within bounds
    canDecrement: state.count > 0,    // Calculate derived properties
  );
}
```

```dart
// Define UI state
class CounterUiState extends BinderState {
  final int count;
  final bool canDecrement;
  
  const CounterUiState({required this.count, required this.canDecrement});
  
  @override
  List<Object?> get props => [count, canDecrement];
}

// Create a binder
class CounterBinder extends FeatureBinder<CounterEvent, CounterState, CounterUiState, SideEffect> {
  CounterBinder({required BuildContext context})
      : super(
          context: context,
          feature: CounterFeature(),
          uiStatePreprocessor: () => const CounterUiState(count: 0, canDecrement: false),
        );

  void increment() => feature.add(IncrementEvent());

  @override
  CounterUiState uiStateTransformer(CounterState featureState) {
    return CounterUiState(
      count: featureState.count,
      canDecrement: featureState.count > 0,
    );
  }
}
```

</details>

### Interface Layer

The interface layer consists of UI widgets that connect to binders.

- **BoundWidget**: Base class for widgets bound to a binder
- **SimpleBoundWidget**: For widgets using SimpleBinder

<details>
<summary><span style="color: purple;">Click to expand</span> Interface Layer example</summary>

```dart
class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CounterWidget(binder: CounterBinder(context: context));
  }
}

class _CounterWidget extends BoundWidget<CounterBinder> {
  const _CounterWidget({required CounterBinder binder}) : super(binder: binder);

  @override
  Widget builder(BuildContext context, CounterBinder binder) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: binder.bindState((context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Count: ${state.count}'),
              ElevatedButton(
                onPressed: binder.increment,
                child: Text('Increment'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
```

</details>

## Examples

Check out the [example](example) directory for complete examples:

1. **Simple Binder Example** - Basic state management without Feature
2. **Feature Binder Example** - Single feature with state management
3. **Side Effects Example** - Feature with side effects like navigation
4. **Multi-Feature Example** - Combining multiple features in one UI
5. **Wait For All Features Example** - Using shouldWaitForAllFeatures = true in MultiFeatureBinder (UI waits for all features before updating)
6. **Concurrent Events Example** - Demonstrates sequential vs concurrent event processing with sync parameter
7. **DisposableBinderProvider Example** - Automatic lifecycle management for temporary form state
8. **bindField Example** - Optimized UI updates by listening to specific state fields instead of entire state

Tests
-----

Automated tests for the example projects are included under `example/test`. These demonstrate usage of the `featureTest` helper, cover state and side-effect assertions, and include concurrent-event scenarios. Run them with `flutter test` from the `example` directory.

### Feature Binder Example

<details>
<summary><span style="color: purple;">Click to expand</span> complete Feature-Binder-Interface example</summary>

```dart
// Events
abstract class CounterEvent extends UiEvent {}
class IncrementEvent extends CounterEvent {}
class DecrementEvent extends CounterEvent {}
class ResetEvent extends CounterEvent {}

// Feature State
class CounterState extends FeatureState {
  final int count;
  const CounterState({this.count = 0});
  
  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
  
  @override
  List<Object?> get props => [count];
}

// UI State
class CounterUiState extends BinderState {
  final int count;
  final String countText;
  final bool canDecrement;

  const CounterUiState({
    required this.count,
    required this.countText,
    required this.canDecrement,
  });

  @override
  List<Object?> get props => [count, countText, canDecrement];
}

// Feature
class CounterFeature extends Feature<CounterEvent, CounterState, SideEffect> {
  CounterFeature() : super(initialState: const CounterState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(CounterEvent event) {
    switch (event) {
      case IncrementEvent():
        emitState(state.copyWith(count: state.count + 1));
      case DecrementEvent():
        if (state.count > 0) {
          emitState(state.copyWith(count: state.count - 1));
        }
      case ResetEvent():
        emitState(const CounterState(count: 0));
    }
  }
}

// Binder
class CounterBinder extends FeatureBinder<CounterEvent, CounterState, CounterUiState, SideEffect> {
  CounterBinder({required BuildContext context})
      : super(
          context: context,
          feature: CounterFeature(),
          uiStatePreprocessor: () => const CounterUiState(
            count: 0,
            countText: '0',
            canDecrement: false,
          ),
        );

  void increment() => feature.add(IncrementEvent());
  void decrement() => feature.add(DecrementEvent());
  void reset() => feature.add(ResetEvent());

  @override
  CounterUiState uiStateTransformer(CounterState featureState) {
    return CounterUiState(
      count: featureState.count,
      countText: '${featureState.count}',
      canDecrement: featureState.count > 0,
    );
  }
}

// Interface (UI)
class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CounterWidget(binder: CounterBinder(context: context));
  }
}

class _CounterWidget extends BoundWidget<CounterBinder> {
  const _CounterWidget({required CounterBinder binder}) : super(binder: binder);

  @override
  Widget builder(BuildContext context, CounterBinder binder) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: binder.bindState((context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Count: ${state.countText}', 
                style: Theme.of(context).textTheme.headlineMedium
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: state.canDecrement ? binder.decrement : null,
                    child: const Text('-'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: binder.increment,
                    child: const Text('+'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: binder.reset,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
```

</details>

### Multi-Feature Example

<details>
<summary><span style="color: purple;">Click to expand</span> Multi-Feature Example code</summary>

Here's an example demonstrating how to combine multiple features in a single UI using MultiFeatureBinder:

```dart
// User Feature Events & State
abstract class UserEvent extends UiEvent {}
class LoadUserEvent extends UserEvent {}
class UpdateUserNameEvent extends UserEvent {
  final String name;
  UpdateUserNameEvent(this.name);
}

class UserState extends FeatureState {
  final bool isLoading;
  final String name;
  final String email;
  final String? error;

  const UserState({
    this.isLoading = false,
    this.name = '',
    this.email = '',
    this.error,
  });

  UserState copyWith({bool? isLoading, String? name, String? email, String? error}) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      email: email ?? this.email,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, name, email, error];
}

// Settings Feature Events & State
abstract class SettingsEvent extends UiEvent {}
class LoadSettingsEvent extends SettingsEvent {}
class ToggleDarkModeEvent extends SettingsEvent {}

class SettingsState extends FeatureState {
  final bool isLoading;
  final bool darkMode;
  final bool notificationsEnabled;
  final String? error;

  const SettingsState({
    this.isLoading = false,
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.error,
  });

  SettingsState copyWith({bool? isLoading, bool? darkMode, bool? notificationsEnabled, String? error}) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, darkMode, notificationsEnabled, error];
}

// Combined UI State
class DashboardState extends BinderState {
  final bool isLoading;
  final String userName;
  final String userEmail;
  final bool darkMode;
  final bool notificationsEnabled;
  final String? error;

  const DashboardState({
    required this.isLoading,
    required this.userName,
    required this.userEmail,
    required this.darkMode,
    required this.notificationsEnabled,
    this.error,
  });

  @override
  List<Object?> get props => [isLoading, userName, userEmail, darkMode, notificationsEnabled, error];
}

// Multi-Feature Binder
class DashboardBinder extends MultiFeatureBinder<DashboardState> {
  DashboardBinder({required BuildContext context})
      : super(
          context: context,
          features: [UserFeature(), SettingsFeature()],
          shouldWaitForAllFeatures: false, // Updates UI immediately when any feature emits state
          uiStatePreprocessor: () => const DashboardState(
            isLoading: true,
            userName: '',
            userEmail: '',
            darkMode: false,
            notificationsEnabled: true,
          ),
        ) {
    // Initialize features
    getFeature<UserFeature>().add(LoadUserEvent());
    getFeature<SettingsFeature>().add(LoadSettingsEvent());
  }

  void updateUserName(String name) {
    getFeature<UserFeature>().add(UpdateUserNameEvent(name));
  }

  void toggleDarkMode() {
    getFeature<SettingsFeature>().add(ToggleDarkModeEvent());
  }

  @override
  DashboardState uiStateTransformer(List<FeatureState> featureStates) {
    final userState = getStateByType<UserState>(featureStates);
    final settingsState = getStateByType<SettingsState>(featureStates);

    return DashboardState(
      isLoading: userState.isLoading || settingsState.isLoading,
      userName: userState.name,
      userEmail: userState.email,
      darkMode: settingsState.darkMode,
      notificationsEnabled: settingsState.notificationsEnabled,
      error: userState.error ?? settingsState.error,
    );
  }
}

// Dashboard UI
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final binder = DashboardBinder(
      context: context, 
      features: [SettingsFeature(), UserFeature()]
    );
    return _DashboardWidget(binder: binder);
  }
}

class _DashboardWidget extends BoundWidget<DashboardBinder> {
  const _DashboardWidget({required DashboardBinder binder}) : super(binder: binder);

  @override
  Widget builder(BuildContext context, DashboardBinder binder) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Feature Dashboard')),
      body: binder.bindState((context, state) {
        return state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User: ${state.userName}', style: Theme.of(context).textTheme.headlineSmall),
                    Text('Email: ${state.userEmail}'),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: state.darkMode,
                      onChanged: (_) => binder.toggleDarkMode(),
                    ),
                    SwitchListTile(
                      title: const Text('Notifications'),
                      value: state.notificationsEnabled,
                      onChanged: (_) => binder.toggleNotifications(),
                    ),
                  ],
                ),
              );
      }),
    );
  }
}
```

</details>

## Testing

Testing Features is straightforward with Flutter FBI. We provide a tiny test helper package, `flutter_fbi_test`, which exposes the `featureTest` helper used in the examples below. Install it in your `dev_dependencies` and import it in tests:

<details>
<summary><span style="color: purple;">Click to expand</span> Test dependency setup</summary>

```yaml
dev_dependencies:
  flutter_fbi_test: ^0.1.8
  flutter_test:
    sdk: flutter
```

</details>

Use `featureTest` to verify a feature's emitted states and side effects in a concise, declarative way:

<details>
<summary><span style="color: purple;">Click to expand</span> featureTest usage example</summary>

```dart
import 'package:flutter_fbi_test/flutter_fbi_test.dart';

featureTest<CounterEvent, CounterState, SideEffect>(
  'increments twice',
  build: () => CounterFeature(),
  act: (f) {
    f.add(IncrementEvent());
    f.add(IncrementEvent());
  },
  expect: () => [
    CounterState(count: 1),
    CounterState(count: 2),
  ],
);
```

</details>

### Testing Features

- **State Testing**: Verify Feature state changes with `expect`
- **Side Effect Testing**: Test side effects with `expectSideEffects`
- **Async Support**: Full async/await support for complex scenarios
- **Setup/Teardown**: Optional setup and verification callbacks
- **Seed States**: Set initial states before testing with `seed`
- **Skip Options**: Skip initial states with `skip` parameter

See the `flutter_fbi_test` package for the helper and examples: https://pub.dev/packages/flutter_fbi_test

## Why Flutter FBI?

- **Clean Separation of Concerns**: Each layer has a distinct responsibility
- **Testable Architecture**: Easy to test business logic in isolation with provided testing utilities
- **Reactive by Design**: Built with native Dart streams for reactive programming
- **Lifecycle Management**: Automatically handles disposal of resources
- **Side Effect Handling**: Clean way to handle one-time events like navigation
- **Event Processing**: Queue-based sequential processing with optional concurrent dispatch for performance
- **Multi-Feature Support**: Coordinate multiple features with configurable waiting strategies

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
