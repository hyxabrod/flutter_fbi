import 'dart:async';

import 'package:flutter_fbi/src/feature/feature_entities.dart';
import 'package:rxdart/rxdart.dart';

interface class IFeature {}

/// Event/state feature
abstract class BaseFeature<E extends UiEvent, S extends FeatureState> implements IFeature {
  final PublishSubject<E> _eventPipe = PublishSubject<E>();

  late BehaviorSubject<S> _statePipe;

  Stream<S> get stateStream => _statePipe.stream.distinct(
        (previous, next) => previous.props.hashCode == next.props.hashCode,
      );

  S get state => _statePipe.value;

  IncomingEventsHandler<E>? _incomingEventsHandler;

  BaseFeature({required S initialState}) {
    _statePipe = BehaviorSubject<S>.seeded(initialState);
    _eventPipe.listen((value) {
      if (_incomingEventsHandler != null) {
        _incomingEventsHandler!(value);
      }
    });
  }

  void onEvent(IncomingEventsHandler<E> handler) {
    _incomingEventsHandler = handler;
  }

  void add(covariant E event) => _eventPipe.add(event);

  void emitState(covariant S state) {
    _statePipe.add(state);
  }

  void dispose() {
    _eventPipe.close();
    _statePipe.close();
  }
}

typedef IncomingEventsHandler<E extends UiEvent> = void Function(E event);

/// Event/state/side-effect feature
abstract class Feature<E extends UiEvent, S extends FeatureState, F extends SideEffect> extends BaseFeature<E, S> {
  late BehaviorSubject<F> sideEffect;

  Feature({required S initialState}) : super(initialState: initialState) {
    sideEffect = BehaviorSubject();
  }

  void emitSifeEffect(covariant F state) {
    sideEffect.add(state);
  }

  @override
  void dispose() {
    sideEffect.close();
    super.dispose();
  }
}
