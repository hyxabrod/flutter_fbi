import 'dart:async';
import 'dart:collection';

import 'package:flutter_fbi/src/feature/feature_entities.dart';
import 'package:flutter_fbi/src/utils/behavior_subject.dart';

/// Base implementation of an event → state feature.
///
/// Processes incoming UI events and exposes a stream of feature states.
/// By default events are queued and handled sequentially; callers may
/// dispatch events concurrently by using `sync: false` when calling [add].
abstract class BaseFeature<E extends UiEvent, S extends FeatureState> {
  final Queue<E> _eventQueue = Queue<E>();
  bool _isProcessing = false;
  late FbiBehaviorSubject<S> _statePipe;

  /// Stream of feature states.
  ///
  /// The stream emits the current state and subsequent updates. Successive
  /// states are filtered using `distinct` semantics based on `props.hashCode`.
  Stream<S> get stateStream => _statePipe.stream.distinct(
        (previous, next) => previous.props.hashCode == next.props.hashCode,
      );

  /// Synchronously accessible current feature state.
  S get state => _statePipe.value;

  IncomingEventsHandler<E>? _incomingEventsHandler;

  /// Creates a feature initialized with [initialState].
  ///
  /// The initial state is seeded into the internal state subject so that
  /// subscribers immediately receive a valid state value.
  BaseFeature({required S initialState}) {
    _statePipe = FbiBehaviorSubject<S>.seeded(initialState);
  }

  /// Register a handler that will be invoked for incoming events.
  ///
  /// The provided [handler] is called for each event added via [add].
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

  /// Emit a new feature state to [stateStream].
  void emitState(covariant S state) {
    _statePipe.add(state);
  }

  /// Dispose the feature and release resources.
  ///
  /// Clears internal queues and closes the internal state stream.
  void dispose() {
    _eventQueue.clear();
    _statePipe.close();
  }
}

typedef IncomingEventsHandler<E extends UiEvent> = FutureOr<void> Function(E event);

/// Feature with optional side-effects stream.
///
/// Extends [BaseFeature] and exposes a [sideEffect] stream that can be used
/// to emit one-off effects (navigation, toasts, logging, etc.).
abstract class Feature<E extends UiEvent, S extends FeatureState, F extends SideEffect> extends BaseFeature<E, S> {
  /// Stream subject for one-off side effects.
  late FbiBehaviorSubject<F> sideEffect;

  /// Creates a feature with the provided [initialState].
  Feature({required S initialState}) : super(initialState: initialState) {
    sideEffect = FbiBehaviorSubject();
  }

  /// Emit a side effect to [sideEffect] stream.
  void emitSideEffect(covariant F state) {
    sideEffect.add(state);
  }

  @override

  /// Dispose both side effects stream and the base feature resources.
  void dispose() {
    sideEffect.close();
    super.dispose();
  }
}

/// Convenience feature type for features that do not keep state.
///
/// Uses [EmptyFeatureState] as the feature state type.
abstract class NoStateFeature<E extends UiEvent, F extends SideEffect> extends Feature<E, EmptyFeatureState, F> {
  NoStateFeature() : super(initialState: EmptyFeatureState());
}
