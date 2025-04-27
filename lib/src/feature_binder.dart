import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/binder_state.dart';
import 'package:flutter_fbi/src/feature.dart';
import 'package:flutter_fbi/src/feature_entities.dart';
import 'package:rxdart/subjects.dart';

typedef BoundWidgetBuilder<S extends BinderState> = Widget Function(
    BuildContext context, S state);

/// Binder
abstract class Binder<F extends FeatureState, S extends BinderState> {
  S uiStateTransformer(F featureState);

  Widget bindState(covariant BoundWidgetBuilder<S> builder);

  void dispose();
}

abstract class BaseFeatureBinder<E extends UiEvent, F extends FeatureState,
    S extends BinderState> implements Binder<F, S> {
  final BuildContext context;
  final BaseFeature<E, F> feature;
  late BehaviorSubject<S> _uiStatePipe;
  StreamSubscription<S>? _featureStreamSubscription;

  S get state => _uiStatePipe.value;

  BaseFeatureBinder(
      {required this.context, required this.feature, required S initialState}) {
    _uiStatePipe = BehaviorSubject.seeded(initialState);
    _featureStreamSubscription ??=
        feature.stateStream.transform(stateTransformer()).listen((event) {
      _uiStatePipe.add(event);
    });
  }

  @override
  Widget bindState(BoundWidgetBuilder<S> builder) {
    return StreamBuilder<S>(
      stream: _uiStatePipe.stream.distinct(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox.shrink();
        } else {
          return builder(context, snapshot.data!);
        }
      },
    );
  }

  void emitUiState(S state) {
    _uiStatePipe.add(state);
  }

  StreamTransformer<F, S> stateTransformer() {
    return StreamTransformer.fromHandlers(handleData: (data, sink) {
      sink.add(uiStateTransformer(data));
    });
  }

  @override
  void dispose() {
    _featureStreamSubscription?.cancel();
    _uiStatePipe.close();
    feature.dispose();
  }
}

abstract class FeatureBinder<E extends UiEvent, F extends FeatureState,
        S extends BinderState, SF extends SideEffect>
    extends BaseFeatureBinder<E, F, S> implements Binder<F, S> {
  final Feature<E, F, SF> _binderFeature;
  StreamSubscription<SF>? _sideEffectSubscription;

  FeatureBinder(
      {required BuildContext context,
      required Feature<E, F, SF> feature,
      required S initialState})
      : _binderFeature = feature,
        super(
          context: context,
          feature: feature,
          initialState: initialState,
        );

  FeatureBinder<E, F, S, SF> bindSideEffect(final void Function(SF) listener) {
    _sideEffectSubscription ??= _binderFeature.sideEffect.listen((effect) {
      listener(effect);
    });
    return this;
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    _binderFeature.dispose();
    super.dispose();
  }
}
