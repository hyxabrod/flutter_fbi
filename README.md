# Flutter FBI

**F**eature. **B**inder. **I**nterface.

A clean architecture pattern for Flutter applications that separates concerns into three distinct layers.

## Overview

Flutter FBI provides a structured approach to Flutter application development by separating your code into three layers:

1. **Feature** - Manages business logic and state
2. **Binder** - Connects features to UI and transforms state
3. **Interface** - UI components that display data and capture user input

## Installation

```yaml
dependencies:
  flutter_fbi: ^1.3.10
```

## Components

### Feature Layer

Features manage the business logic and state of your application.

- **BaseFeature**: Process events and emit states
- **Feature**: Extends BaseFeature to also handle side effects (one-time events)

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
    if (event is IncrementEvent) {
      emitState(CounterState(count: state.count + 1));
    }
  }
}
```

### Binder Layer

Binders connect features to the UI and transform feature states into UI states.

- **SimpleBinder**: For UI state without a feature
- **FeatureBinder**: Connects a single feature to UI
- **MultiFeatureBinder**: Connects multiple features to UI

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
5. **Wait For All Features Example** - Using shouldNotWaitForAllFeatures = false in MultiFeatureBinder (UI waits for all features before updating)

## Why Flutter FBI?

- **Clean Separation of Concerns**: Each layer has a distinct responsibility
- **Testable Architecture**: Easy to test business logic in isolation
- **Reactive by Design**: Built on RxDart for reactive programming
- **Lifecycle Management**: Automatically handles disposal of resources
- **Side Effect Handling**: Clean way to handle one-time events like navigation

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
