import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';

/// Binder
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

  Widget bindState(covariant BoundWidgetBuilder<S> builder);
  void emitUiState(S state);
  void dispose();
}

abstract class Binder<F extends FeatureState, S extends BinderState>
    extends BasicBinder<S> {
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
