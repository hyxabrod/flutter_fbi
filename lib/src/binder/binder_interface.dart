import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';

typedef BoundWidgetBuilder<S extends BinderState> = Widget Function(BuildContext context, S state);

/// Base binder with common bindState implementation
abstract class BasicBinder<S extends BinderState> {
  final BuildContext context;
  final S Function() uiStatePreprocessor;
  final Widget? errorWidget;
  final Widget? emptyDataWidget;

  BasicBinder({
    required this.context,

    /// Function that preprocesses the state before applying updates.
    ///
    /// This function allows transforming or validating the state before
    /// it gets updated in the binder. It takes the current state and returns
    /// a processed version of that state.
    required this.uiStatePreprocessor,
    this.errorWidget,
    this.emptyDataWidget,
  });

  /// Common bindState implementation that all binders can use
  Widget bindState(BoundWidgetBuilder<S> builder) {
    return StreamBuilder<S>(
      stream: getStateStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return builder(context, snapshot.data!);
        } else if (snapshot.hasError) {
          return errorWidget ?? const SizedBox.shrink();
        } else {
          return emptyDataWidget ?? const SizedBox.shrink();
        }
      },
    );
  }

  /// Binds a specific field from the state and rebuilds only when that field changes.
  ///
  /// Example:
  /// ```dart
  /// binder.bindField(
  ///   selector: (state) => state.count,
  ///   builder: (context, count) => Text('$count'),
  /// )
  /// ```
  Widget bindField<T>({
    required T Function(S state) selector,
    required Widget Function(BuildContext context, T value) builder,
  }) {
    return StreamBuilder<T>(
      stream: getStateStream().map(selector).distinct(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return builder(context, snapshot.data as T);
        } else if (snapshot.hasError) {
          return errorWidget ?? const SizedBox.shrink();
        } else {
          return emptyDataWidget ?? const SizedBox.shrink();
        }
      },
    );
  }

  /// Subclasses must provide their state stream
  Stream<S> getStateStream();
  
  void emitUiState(S state);
  void dispose();
}

abstract class Binder<F extends FeatureState, S extends BinderState> extends BasicBinder<S> {
  Binder({
    required super.context,
    required super.uiStatePreprocessor,
    super.errorWidget,
    super.emptyDataWidget,
  });

  S uiStateTransformer(F featureState);
}

abstract class MultiBinder<S extends BinderState> extends BasicBinder<S> {
  MultiBinder({
    required super.context,
    required super.uiStatePreprocessor,
    super.errorWidget,
    super.emptyDataWidget,
  });
  S uiStateTransformer(List<FeatureState> featureState);
}
