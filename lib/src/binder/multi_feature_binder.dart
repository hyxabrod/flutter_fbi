import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:flutter_fbi/src/binder/binder_state.dart';
import 'package:flutter_fbi/src/feature/feature.dart';
import 'package:flutter_fbi/src/binder/feature_binder.dart';
import 'package:flutter_fbi/src/feature/feature_entities.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseMultiFeatureBinder<S extends BinderState> implements MultiBinder<S> {
  final BuildContext context;
  final List<BaseFeature> featureList;
  late BehaviorSubject<S> _uiStatePipe;
  StreamSubscription<S>? _featureStreamSubscription;
  final Widget? errorWidget;
  final Widget? emptyDataWidget;
  final S Function()? preprocessor;

  S get state => _uiStatePipe.value;

  BaseMultiFeatureBinder({
    required this.context,
    required this.featureList,
    required S initialState,
    this.emptyDataWidget,
    this.errorWidget,
    this.preprocessor,
  }) {
    assert(featureList.isNotEmpty, 'Feature list cannot be empty');
    _uiStatePipe = BehaviorSubject.seeded(preprocessor == null ? initialState : preprocessor!());

    _featureStreamSubscription = Rx.combineLatest<FeatureState, S>(
      featureList.map((e) => e.stateStream),
      (featureStates) => uiStateTransformer(
        featureStates,
      ),
    ).listen((binderState) => _uiStatePipe.add(binderState));
  }

  @override
  Widget bindState(BoundWidgetBuilder<S> builder) {
    return StreamBuilder<S>(
      stream: _uiStatePipe.stream.distinct(),
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

  void emitState(S state) {
    _uiStatePipe.add(state);
  }

  @override
  void dispose() {
    _featureStreamSubscription?.cancel();
    _uiStatePipe.close();
    for (var e in featureList) {
      e.dispose();
    }
  }
}

/// Binder
abstract class MultiFeatureBinder<S extends BinderState> extends BaseMultiFeatureBinder<S> implements MultiBinder<S> {
  final List<Feature> _binderFeatures;
  StreamSubscription<SideEffect>? _sideEffectSubscription;

  MultiFeatureBinder({required BuildContext context, required List<Feature> features, required S initialState})
      : _binderFeatures = features,
        super(
          context: context,
          featureList: features,
          initialState: initialState,
        );

  MultiFeatureBinder<S> bindSideEffect(final void Function(SideEffect) listener) {
    _sideEffectSubscription ??= Rx.merge(_binderFeatures.map((e) => e.sideEffect)).listen(
      (effect) {
        listener(effect);
      },
    );
    return this;
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    for (var e in _binderFeatures) {
      e.dispose();
    }
    super.dispose();
  }
}
