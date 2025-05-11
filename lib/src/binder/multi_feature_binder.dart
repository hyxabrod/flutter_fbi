import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:flutter_fbi/src/binder/binder_state.dart';
import 'package:flutter_fbi/src/feature/feature.dart';
import 'package:flutter_fbi/src/binder/feature_binder.dart';
import 'package:flutter_fbi/src/feature/feature_entities.dart';
import 'package:rxdart/rxdart.dart';

/// Base class for multi-feature binders.
abstract class _BaseMultiFeatureBinder<S extends BinderState> extends MultiBinder<S> {
  final List<BaseFeature> featureList;
  late BehaviorSubject<S> _uiStatePipe;
  StreamSubscription<S>? _featureStreamSubscription;
  S get state => _uiStatePipe.value;

  _BaseMultiFeatureBinder({
    required super.context,
    required this.featureList,
    required super.uiStatePreprocessor,
    super.emptyDataWidget,
    super.errorWidget,

    /// Whether to wait for all features to be ready before proceeding.
    /// Defaults to `false`.
    bool shouldWaitForAllFeatures = false,
  }) {
    assert(featureList.isNotEmpty, 'Feature list cannot be empty');
    _uiStatePipe = BehaviorSubject.seeded(uiStatePreprocessor());

    final instantUpdate = Rx.merge(featureList
            .map(
              (feature) => feature.stateStream,
            )
            .toList())
        .map<S>((state) => uiStateTransformer([state]));

    final combinedUpdate = Rx.combineLatest<FeatureState, S>(
      featureList.map((e) => e.stateStream),
      (featureStates) => uiStateTransformer(
        featureStates,
      ),
    );

    _featureStreamSubscription = (shouldWaitForAllFeatures ? combinedUpdate : instantUpdate).listen(
      (binderState) => _uiStatePipe.add(binderState),
    );
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

  @override
  void emitUiState(S state) {
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

/// An abstract class for binding multiple features with a shared state.
///
/// Type `S` represents the type of the binder's state.
abstract class MultiFeatureBinder<S extends BinderState> extends _BaseMultiFeatureBinder<S> {
  final List<Feature> _binderFeatures;
  StreamSubscription<SideEffect>? _sideEffectSubscription;

  MultiFeatureBinder({
    required super.context,
    required List<Feature> features,

    /// Function that preprocesses the state before applying updates.
    ///
    /// This function allows transforming or validating the state before
    /// it gets updated in the binder. It takes the current state and returns
    /// a processed version of that state.
    required super.uiStatePreprocessor,
    Widget? errorWidget,
    Widget? emptyDataWidget,
  })  : _binderFeatures = features,
        super(
          featureList: features,
          errorWidget: errorWidget,
          emptyDataWidget: emptyDataWidget,
        );

  /// Binds a listener function to be called when a [SideEffect] is emitted.
  ///
  /// The [listener] function will receive the [SideEffect] as an argument.
  /// Returns this [MultiFeatureBinder] instance for chaining.
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
