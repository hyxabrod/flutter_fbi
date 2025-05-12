# Flutter FBI Example

This project demonstrates the use of the Flutter FBI (Feature, Binder, Interface) architecture pattern for building Flutter applications.

## Overview

Flutter FBI is an architectural pattern that separates your application into three distinct layers:

1. **Feature** - Manages business logic and state
2. **Binder** - Connects features to UI and transforms state
3. **Interface** - UI components that display data and capture user input

## Examples

This project includes five examples that progressively demonstrate the capabilities of the Flutter FBI pattern:

### Example 1: Simple Binder
A basic counter example that uses `SimpleBinder` for UI state management without the complexity of a separate Feature.

### Example 2: Feature Binder Basic
A counter example that uses `BaseFeature` and `FeatureBinder` to separate business logic from UI.

### Example 3: Feature with Side Effects
A login/authentication example that demonstrates how to handle side effects (one-time events like navigation or toasts) with `Feature` and `FeatureBinder`.

### Example 4: Multi-Feature Binder
A dashboard example that combines multiple features (User Profile and Settings) using `MultiFeatureBinder`.

**This example uses `shouldNotWaitForAllFeatures = true` (the UI does NOT wait for all features before updating).**

- The UI updates as soon as any feature emits a new state, so partial data may be shown if one feature loads before the others.
- This is useful for fast, responsive dashboards where immediate feedback is preferred over synchronized updates.

### Example 5: Multi-Feature Binder with Wait
A dashboard example that demonstrates the use of `shouldNotWaitForAllFeatures = false` (wait for all features before updating UI).` option, which ensures that the UI waits for all features to emit at least one state before transforming the state for UI.

## Getting Started

1. Run the example app:
   ```
   cd example
   flutter run
   ```

2. Navigate through the different examples to see how the FBI pattern works in various scenarios.

## How It Works

- Features use RxDart streams to process events and emit states.
- Binders transform feature states into UI-friendly states and handle side effects.
- Bound widgets automatically connect to binders and handle their lifecycle.

## License

This example is part of the Flutter FBI package and is subject to the same license.
