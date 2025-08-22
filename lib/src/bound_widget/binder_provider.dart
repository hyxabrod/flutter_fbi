import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';

/// A provider widget that makes a [BasicBinder] available to its descendants in the widget tree.
///
/// This widget uses the [InheritedWidget] pattern to expose the binder instance
/// down the widget tree, allowing child widgets to access and interact with it.
///
/// The generic type [T] should extend [BasicBinder], which provides the core binding functionality.
///
/// Example usage:
/// ```dart
/// BinderProvider<MyBinder>(
///   binder: myBinder,
///   child: MyWidget(),
/// )
/// ```
///
/// Child widgets can then access the binder using:
/// ```dart
/// final binder = context.findBinder<MyBinder>();
/// ```
class BinderProvider<T extends BasicBinder> extends InheritedWidget {
  final T binder;

  const BinderProvider({
    Key? key,
    required this.binder,
    required Widget child,
  }) : super(key: key, child: child);

  static T? of<T extends BasicBinder>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<BinderProvider<T>>();
    return provider?.binder;
  }

  @override
  bool updateShouldNotify(BinderProvider oldWidget) {
    return oldWidget.binder != binder;
  }
}

class DisposableBinderProvider<T extends BasicBinder> extends StatefulWidget {
  /// A convenience provider that creates a `BasicBinder` using the provided
  /// `create` factory and automatically disposes it when the provider is
  /// removed from the widget tree.
  ///
  /// Use this when you want the provider to own the binder's lifecycle:
  ///
  /// ```dart
  /// DisposableBinderProvider<MyBinder>(
  ///   create: (context) => MyBinder(context: context, ...),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// The created binder will be accessible to descendants via
  /// `BinderProvider.of<T>(context)` and will have `dispose()` called
  /// automatically in `dispose()` of this widget's state.
  final T Function(BuildContext) create;
  final Widget child;
  const DisposableBinderProvider({required this.create, required this.child, Key? key}) : super(key: key);

  @override
  State<DisposableBinderProvider<T>> createState() => _DisposableBinderProviderState<T>();
}

class _DisposableBinderProviderState<T extends BasicBinder> extends State<DisposableBinderProvider<T>> {
  late final T binder;

  @override
  void initState() {
    super.initState();
    binder = widget.create(context);
  }

  @override
  void dispose() {
    binder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BinderProvider<T>(binder: binder, child: widget.child);
}
