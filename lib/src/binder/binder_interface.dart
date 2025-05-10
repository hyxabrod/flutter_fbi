import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';


/// Binder
abstract class BasicBinder<S extends BinderState> {
  final BuildContext context;
  final S Function() statePreprocessor;
  final Widget? errorWidget;
  final Widget? emptyDataWidget;

  BasicBinder({
    required this.context,
    required this.statePreprocessor,
    this.errorWidget,
    this.emptyDataWidget,
  });

  Widget bindState(covariant BoundWidgetBuilder<S> builder);
  void emitUiState(S state);
  void dispose();
}

abstract class Binder<F extends FeatureState, S extends BinderState> extends BasicBinder<S> {
  Binder({
    required super.context,
    required super.statePreprocessor,
    super.errorWidget,
    super.emptyDataWidget,
  });

  S uiStateTransformer(F featureState);
}

abstract class MultiBinder<S extends BinderState> extends BasicBinder<S> {
  MultiBinder({
    required super.context,
    required super.statePreprocessor,
    super.errorWidget,
    super.emptyDataWidget,
  });
  S uiStateTransformer(List<FeatureState> featureState);
}
