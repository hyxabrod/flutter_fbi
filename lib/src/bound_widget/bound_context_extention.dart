import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
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
    final provider =
        context.dependOnInheritedWidgetOfExactType<BinderProvider<T>>();
    return provider?.binder;
  }

  @override
  bool updateShouldNotify(BinderProvider oldWidget) {
    return oldWidget.binder != binder;
  }
}

/// Extension on [BuildContext] that provides binding and access to widget's state.
///
/// This extension offers methods to bind and retrieve stateful data for widgets,
/// allowing for more efficient state management across the widget tree.
///
/// See also:
///  * [BoundWidget], which utilizes this extension for state binding.
extension BinderContextExtension on BuildContext {
  T findBinder<T extends BasicBinder>() {
    final foundBinder = BinderProvider.of<T>(this);
    if (foundBinder == null) {
      throw Exception(
          'No binder of type $T found in the current widget subtree');
    }
    return foundBinder;
  }

  T? findBinderOrNull<T extends BasicBinder>() {
    return BinderProvider.of<T>(this);
  }
}
