import 'dart:async';

/// Minimal BehaviorSubject replacement without RxDart.
///
/// - Stores the latest value and exposes it via [value].
/// - New subscribers receive the latest value immediately if present.
/// - Backed by an internal broadcast stream.
class BehaviorSubject<T> extends Stream<T> {
  final StreamController<T> _controller;
  T? _last;
  bool _hasValue;
  bool _isClosed = false;
  _BehaviorSubjectSink<T>? _cachedSink;

  /// Creates an empty subject (no initial value).
  BehaviorSubject({bool sync = false})
      : _controller = StreamController<T>.broadcast(sync: sync),
        _hasValue = false;

  /// Creates a subject seeded with an initial value.
  BehaviorSubject.seeded(T initialValue, {bool sync = false})
      : _controller = StreamController<T>.broadcast(sync: sync),
        _last = initialValue,
        _hasValue = true;

  /// Whether the subject currently holds a value.
  bool get hasValue => _hasValue;

  /// Whether the subject has been closed.
  bool get isClosed => _isClosed;

  /// Returns the last value or null if none has been set yet.
  T? get valueOrNull => _hasValue ? _last : null;

  /// A sink that preserves BehaviorSubject semantics when adding.
  ///
  /// Note: this is a proxy; do not hold the underlying controller's sink
  /// directly, otherwise `_last` would not be updated on `add`.
  StreamSink<T> get sink => _cachedSink ??= _BehaviorSubjectSink<T>(this);

  /// Exposes a stream that replays the latest value to each new listener.
  Stream<T> get stream => Stream<T>.multi((multi) {
        if (_hasValue) {
          multi.add(_last as T);
        }
        final sub = _controller.stream.listen(
          multi.add,
          onError: multi.addError,
          onDone: multi.close,
          cancelOnError: false,
        );
        multi.onCancel = () => sub.cancel();
      }, isBroadcast: true);

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Returns the latest value or throws [StateError] if none.
  T get value {
    if (!_hasValue) {
      throw StateError('BehaviorSubject has no value');
    }
    return _last as T;
  }

  /// Emits a new value to listeners and stores it as the latest value.
  void add(T event) {
    if (_isClosed) return;
    _last = event;
    _hasValue = true;
    _controller.add(event);
  }

  /// Emits an error to listeners.
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed) return;
    _controller.addError(error, stackTrace);
  }

  /// Closes the subject.
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await _controller.close();
  }
}

class _BehaviorSubjectSink<T> implements StreamSink<T> {
  final BehaviorSubject<T> _subject;
  _BehaviorSubjectSink(this._subject);

  @override
  void add(T data) => _subject.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _subject.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<T> stream, {bool? cancelOnError}) {
    final completer = Completer<void>();
    late final StreamSubscription<T> sub;
    sub = stream.listen(
      (event) => _subject.add(event),
      onError: (Object error, StackTrace stack) {
        _subject.addError(error, stack);
        if (cancelOnError == true && !completer.isCompleted) {
          sub.cancel();
          completer.completeError(error, stack);
        }
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: cancelOnError ?? false,
    );
    return completer.future;
  }

  @override
  Future<void> close() => _subject.close();

  @override
  Future<void> get done => _subject._controller.done;
}
