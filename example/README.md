# Flutter FBI Example

This project demonstrates the use of the Flutter FBI (Feature, Binder, Interface) architecture pattern for building Flutter applications.

## Overview

Flutter FBI is an architectural pattern that separates your application into three distinct layers:

1. **Feature** - Manages business logic and state
2. **Binder** - Connects features to UI and transforms state
3. **Interface** - UI components that display data and capture user input

## Examples

This project includes six examples that progressively demonstrate the capabilities of the Flutter FBI pattern:

### Example 1: Simple Binder
A basic counter example that uses `SimpleBinder` for UI state management without the complexity of a separate Feature.

### Example 2: Feature Binder Basic
A counter example that uses `BaseFeature` and `FeatureBinder` to separate business logic from UI.

### Example 3: Feature with Side Effects
A login/authentication example that demonstrates how to handle side effects (one-time events like navigation or toasts) with `Feature` and `FeatureBinder`.

### Example 4: Multi-Feature Binder
A dashboard example that combines multiple features (User Profile and Settings) using `MultiFeatureBinder`.

**This example uses `shouldWaitForAllFeatures = false` (the UI does NOT wait for all features before updating).**

- The UI updates as soon as any feature emits a new state, so partial data may be shown if one feature loads before the others.
- This is useful for fast, responsive dashboards where immediate feedback is preferred over synchronized updates.

### Example 5: Multi-Feature Binder with Wait
A dashboard example that demonstrates the use of `shouldWaitForAllFeatures = true` option, which ensures that the UI waits for all features to emit at least one state before transforming the state for UI.

### Example 6: Concurrent Events (sync: false)
Demonstrates how to dispatch events concurrently using the `sync: false` parameter in `feature.add()`. This example shows how fast events can bypass the sequential queue and be processed immediately, while slow events are processed in order.

## Getting Started

1. Run the example app:
   ```
   cd example
   flutter run
   ```

2. Navigate through the different examples to see how the FBI pattern works in various scenarios.

## How It Works

- Features use queue-based event processing with optional concurrent dispatch (`sync: false`)
- Events are processed sequentially by default to ensure predictable state transitions
- Binders transform feature states into UI-friendly states and handle side effects
- Bound widgets automatically connect to binders and handle their lifecycle
- Side effects are handled separately from state for clean separation of concerns

## License

This example is part of the Flutter FBI package and is subject to the same license.
