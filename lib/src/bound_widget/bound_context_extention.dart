import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/bound_widget/binder_provider.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';

/// Extension on [BuildContext] that provides binding and access to widget's state.
///
/// This extension offers methods to bind and retrieve stateful data for widgets,
/// allowing for more efficient state management across the widget tree.
extension BinderContextExtension on BuildContext {
  T findBinder<T extends BasicBinder>() {
    final foundBinder = BinderProvider.of<T>(this);
    if (foundBinder == null) {
      throw Exception('No binder of type $T found in the current widget subtree');
    }
    return foundBinder;
  }

  T? findBinderOrNull<T extends BasicBinder>() {
    return BinderProvider.of<T>(this);
  }
}
