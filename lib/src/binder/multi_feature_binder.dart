import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:flutter_fbi/src/binder/binder_state.dart';
import 'package:flutter_fbi/src/feature/feature.dart';
import 'package:flutter_fbi/src/feature/feature_entities.dart';
import 'package:flutter_fbi/src/utils/behavior_subject.dart';
import 'package:flutter_fbi/src/utils/stream_utils.dart';

/// Base class for multi-feature binders.
abstract class _BaseMultiFeatureBinder<S extends BinderState> extends MultiBinder<S> {
  final List<BaseFeature> featureList;
  late BehaviorSubject<S> _uiStatePipe;
  StreamSubscription<S>? _featureStreamSubscription;
  bool _isDisposed = false;
  S get state => _uiStatePipe.value;

  _BaseMultiFeatureBinder({
    required super.context,
    required this.featureList,
    required super.uiStatePreprocessor,
    super.emptyDataWidget,
    super.errorWidget,

    /// Whether to wait for all features to be ready before proceeding.
    /// Defaults to `true`.
    bool shouldWaitForAllFeatures = true,
  }) {
    assert(featureList.isNotEmpty, 'Feature list cannot be empty');
    _uiStatePipe = BehaviorSubject.seeded(uiStatePreprocessor());

    // Conditional stream creation to avoid unnecessary operations
    if (shouldWaitForAllFeatures) {
      final combinedUpdate = StreamUtils.combineLatest<FeatureState, S>(
        featureList.map((e) => e.stateStream),
        (featureStates) => uiStateTransformer(featureStates),
      );
      _featureStreamSubscription = combinedUpdate.listen(
        (binderState) => _uiStatePipe.add(binderState),
      );
    } else {
      final instantUpdate = StreamUtils.merge(featureList
              .map((feature) => feature.stateStream)
              .toList())
          .map<S>((state) => uiStateTransformer([state]));
      _featureStreamSubscription = instantUpdate.listen(
        (binderState) => _uiStatePipe.add(binderState),
      );
    }
  }

  @override
  Stream<S> getStateStream() => _uiStatePipe.stream.distinct();

  @override
  void emitUiState(S state) {
    _uiStatePipe.add(state);
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
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
    bool shouldWaitForAllFeatures = true,
    Widget? errorWidget,
    Widget? emptyDataWidget,
  })  : _binderFeatures = features,
        super(
          featureList: features,
          shouldWaitForAllFeatures: shouldWaitForAllFeatures,
          errorWidget: errorWidget,
          emptyDataWidget: emptyDataWidget,
        );

  /// Binds a listener function to be called when a [SideEffect] is emitted.
  ///
  /// The [listener] function will receive the [SideEffect] as an argument.
  /// Returns this [MultiFeatureBinder] instance for chaining.
  MultiFeatureBinder<S> bindSideEffect(final void Function(SideEffect) listener) {
    _sideEffectSubscription ??= StreamUtils.merge(_binderFeatures.map((e) => e.sideEffect)).listen(
      (effect) {
        listener(effect);
      },
    );
    return this;
  }

  F getFeature<F extends Feature>() {
    for (var feature in _binderFeatures) {
      if (feature is F) {
        return feature;
      }
    }
    throw Exception('Feature of type $F not found in binder');
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    
    _sideEffectSubscription?.cancel();
    // Features will be disposed by super.dispose() to avoid double disposal
    super.dispose();
  }
}
