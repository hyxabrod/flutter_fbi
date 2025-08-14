<div align="center">
  <img src="https://raw.githubusercontent.com/hyxabrod/flutter_fbi/master/flutter_fbi_icon.svg" alt="Flutter FBI Logo" width="120" height="120">
  
  # Flutter FBI

  **F**eature. **B**inder. **I**nterface.

  [![pub package](https://img.shields.io/pub/v/flutter_fbi.svg)](https://pub.dev/packages/flutter_fbi)
  [![Dart 3 compatible](https://img.shields.io/badge/Dart%203-compatible-blue.svg)](https://dart.dev/guides/language/evolution#dart-3)
  [![Flutter compatible](https://img.shields.io/badge/Flutter-compatible-blue.svg)](https://flutter.dev)
</div>

A clean architecture pattern for Flutter applications that separates concerns into three distinct layers.

## Overview

Flutter FBI provides a structured approach to Flutter application development by separating your code into three layers:

1. **Feature** - Manages business logic and state
2. **Binder** - Connects features to UI and transforms state
3. **Interface** - UI components that display data and capture user input

<div align="center">
  <img src="https://raw.githubusercontent.com/hyxabrod/flutter_fbi/master/flutter_fbi_architecture.svg" alt="Flutter FBI Architecture" width="100%">
</div>

<br><br><br>

The architecture supports both single feature scenarios (Feature Binder) and complex multi-feature coordination (Multi Feature Binder), with reactive data flow powered by RxDart streams.

<br><br>

## Installation

```yaml
dependencies:
  flutter_fbi: ^1.3.27
```

## Components

### Feature Layer

Features manage the business logic and state of your application using queue-based event processing for guaranteed ordering.

- **BaseFeature**: Process events sequentially and emit states
- **Feature**: Extends BaseFeature to also handle side effects (one-time events)
- **Event Processing**: Queue-based sequential processing with optional concurrent dispatch

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

### Binder Layer

Binders connect features to the UI and transform feature states into UI states.

- **SimpleBinder**: For UI state without a feature
- **FeatureBinder**: Connects a single feature to UI
- **MultiFeatureBinder**: Connects multiple features to UI

#### uiStatePreprocessor

The `uiStatePreprocessor` is a required function that preprocesses the UI state before it gets applied to the widget. This function allows you to:

- **Transform state**: Modify the state before it reaches the UI
- **Add validation**: Ensure state consistency and validity
- **Apply fallback values**: Provide default values for missing or invalid data
- **Combine data**: Merge data from multiple sources into a single UI state

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

### Interface Layer

The interface layer consists of UI widgets that connect to binders.

- **BoundWidget**: Base class for widgets bound to a binder
- **SimpleBoundWidget**: For widgets using SimpleBinder

```dart
class CounterScreen extends StatelessWidget {
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

## Examples

Check out the [example](example) directory for complete examples:

1. **Simple Binder Example** - Basic state management without Feature
2. **Feature Binder Example** - Single feature with state management
3. **Side Effects Example** - Feature with side effects like navigation
4. **Multi-Feature Example** - Combining multiple features in one UI
5. **Wait For All Features Example** - Using shouldWaitForAllFeatures = true in MultiFeatureBinder (UI waits for all features before updating)
6. **Concurrent Events Example** - Demonstrates sequential vs concurrent event processing with sync parameter

### Feature Binder Example

Here's a complete example of the Feature-Binder-Interface pattern with a counter:

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: BoundWidget<CounterBinder, CounterUiState>(
        binderBuilder: () => CounterBinder(context: context),
        builder: (context, state, binder) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Count: ${state.countText}', style: Theme.of(context).textTheme.headlineMedium),
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
        },
      ),
    );
  }
}
```

### Multi-Feature Example

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
  @override
  Widget build(BuildContext context) {
    return BoundWidget<DashboardBinder, DashboardState>(
      binderBuilder: () => DashboardBinder(context: context),
      builder: (context, state, binder) {
        return Scaffold(
          appBar: AppBar(title: const Text('Multi-Feature Dashboard')),
          body: state.isLoading
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
                ),
        );
      },
    );
  }
}
```

## Testing

Flutter FBI includes comprehensive testing utilities similar to bloc_test for easy Feature testing:

```dart
import 'package:flutter_fbi/flutter_fbi.dart';

void main() {
  featureTest<CounterEvent, CounterState, SideEffect>(
    'counter increments correctly',
    build: () => CounterFeature(),
    act: (feature) async {
      feature.add(IncrementEvent());
      feature.add(IncrementEvent());
    },
    expect: () => [
      CounterState(count: 1),
      CounterState(count: 2),
    ],
  );

  featureTest<AuthEvent, AuthState, AuthSideEffect>(
    'login emits correct states and side effects',
    build: () => AuthFeature(),
    act: (feature) => feature.add(LoginEvent(username: 'user', password: 'pass')),
    expect: () => [
      AuthState(isLoading: true),
      AuthState(isLoading: false, isLoggedIn: true, username: 'user'),
    ],
    expectSideEffects: () => [
      ShowToastEffect('Welcome, user!'),
      NavigateToHomeEffect(),
    ],
  );
}
```

### Testing Features

- **State Testing**: Verify Feature state changes with `expect`
- **Side Effect Testing**: Test side effects with `expectSideEffects`  
- **Async Support**: Full async/await support for complex scenarios
- **Setup/Teardown**: Optional setup and verification callbacks
- **Seed States**: Set initial states before testing with `seed`
- **Timing Control**: Control timing with `wait` parameter
- **Skip Options**: Skip initial states with `skip` parameter

## Why Flutter FBI?

- **Clean Separation of Concerns**: Each layer has a distinct responsibility
- **Testable Architecture**: Easy to test business logic in isolation with provided testing utilities
- **Reactive by Design**: Built on RxDart for reactive programming
- **Lifecycle Management**: Automatically handles disposal of resources
- **Side Effect Handling**: Clean way to handle one-time events like navigation
- **Event Processing**: Queue-based sequential processing with optional concurrent dispatch for performance
- **Multi-Feature Support**: Coordinate multiple features with configurable waiting strategies

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
