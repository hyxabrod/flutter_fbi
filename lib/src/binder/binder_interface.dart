import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';

interface class IBinder {}

/// Binder
abstract interface class BasicBinder<S extends BinderState> {
  Widget bindState(covariant BoundWidgetBuilder<S> builder);

  void dispose();
}

abstract class Binder<F extends FeatureState, S extends BinderState>
    extends BasicBinder<S> {
  S uiStateTransformer(F featureState);
}

abstract interface class MultiBinder<S extends BinderState>
    extends BasicBinder<S> {
  S uiStateTransformer(List<FeatureState> featureState);
}
