import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:flutter_fbi/src/binder/binder_state.dart';
import 'package:flutter_fbi/src/feature/feature.dart';
import 'package:flutter_fbi/src/feature/feature_entities.dart';
import 'package:rxdart/subjects.dart';

typedef BoundWidgetBuilder<S extends BinderState> = Widget Function(BuildContext context, S state);

abstract class BaseFeatureBinder<E extends UiEvent, F extends FeatureState, S extends BinderState>
    extends Binder<F, S> {
  final BaseFeature<E, F> feature;
  late BehaviorSubject<S> _uiStatePipe;
  StreamSubscription<S>? _featureStreamSubscription;

  S get state => _uiStatePipe.value;

  BaseFeatureBinder({
    required super.context,
    required this.feature,
    required super.statePreprocessor,
    super.emptyDataWidget,
    super.errorWidget,
  }) {
    _uiStatePipe = BehaviorSubject.seeded(statePreprocessor());
    _featureStreamSubscription ??= feature.stateStream.transform(stateTransformer()).listen((event) {
      _uiStatePipe.add(event);
    });
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

abstract class FeatureBinder<E extends UiEvent, F extends FeatureState, S extends BinderState, SF extends SideEffect>
    extends BaseFeatureBinder<E, F, S> {
  final Feature<E, F, SF> _binderFeature;
  StreamSubscription<SF>? _sideEffectSubscription;

  FeatureBinder({
    required super.context,
    required Feature<E, F, SF> feature,
    required super.statePreprocessor,
  })  : _binderFeature = feature,
        super(feature: feature);

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
