import 'dart:async';
import 'dart:collection';

import 'package:flutter_fbi/src/feature/feature_entities.dart';
import 'package:rxdart/rxdart.dart';

/// Event/state feature
abstract class BaseFeature<E extends UiEvent, S extends FeatureState> {
  // Removed PublishSubject in favor of explicit queue-based dispatching to
  // guarantee ordering and avoid reentrancy issues.
  final Queue<E> _eventQueue = Queue<E>();
  bool _isProcessing = false;
  late BehaviorSubject<S> _statePipe;

  Stream<S> get stateStream => _statePipe.stream.distinct(
        (previous, next) => previous.props.hashCode == next.props.hashCode,
      );

  S get state => _statePipe.value;

  IncomingEventsHandler<E>? _incomingEventsHandler;

  BaseFeature({required S initialState}) {
    _statePipe = BehaviorSubject<S>.seeded(initialState);
    // We no longer listen to a Subject; events are dispatched via add() which
    // feeds either the sync queue or concurrent path explicitly.
  }

  void onEvent(IncomingEventsHandler<E> handler) {
    _incomingEventsHandler = handler;
  }

  /// Adds an event to be processed.
  ///
  /// By default, events are processed synchronously in the order they are added
  /// (sync = true). Set [sync] to false to dispatch the event
  /// concurrently (scheduled in a microtask) without waiting for the queue.
  void add(covariant E event, {bool sync = true}) {
    if (sync) {
      _eventQueue.add(event);
      _processQueue();
    } else {
      _dispatchConcurrent(event);
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      while (_eventQueue.isNotEmpty) {
        final e = _eventQueue.removeFirst();
        final handler = _incomingEventsHandler;
        if (handler != null) {
          await handler(e);
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _dispatchConcurrent(E event) {
    final handler = _incomingEventsHandler;
    if (handler == null) return;
    // Schedule in a microtask to avoid reentrancy into the current call stack.
    scheduleMicrotask(() async {
      await handler(event);
    });
  }

  void emitState(covariant S state) {
    _statePipe.add(state);
  }

  void dispose() {
    // No Subject to close; clear queue and close state stream.
    _eventQueue.clear();
    _statePipe.close();
  }
}

typedef IncomingEventsHandler<E extends UiEvent> = FutureOr<void> Function(E event);

/// Event/state/side-effect feature
abstract class Feature<E extends UiEvent, S extends FeatureState, F extends SideEffect> extends BaseFeature<E, S> {
  late BehaviorSubject<F> sideEffect;

  Feature({required S initialState}) : super(initialState: initialState) {
    sideEffect = BehaviorSubject();
  }

  void emitSideEffect(covariant F state) {
    sideEffect.add(state);
  }

  @override
  void dispose() {
    sideEffect.close();
    super.dispose();
  }
}

abstract class NoStateFeature<E extends UiEvent, F extends SideEffect> extends Feature<E, EmptyFeatureState, F> {
  NoStateFeature() : super(initialState: EmptyFeatureState());
}
