import 'dart:async';

/// Minimal Rx-like utilities using only dart:async.
class StreamUtils {
  /// Merges multiple streams into a single stream of the same type.
  static Stream<T> merge<T>(Iterable<Stream<T>> streams) {
    final list = streams.toList(growable: false);
    return Stream<T>.multi((multi) {
      if (list.isEmpty) {
        multi.close();
        return;
      }
      final subs = <StreamSubscription<T>>[];
      var doneCount = 0;
      void onDone() {
        doneCount++;
        if (doneCount == list.length) multi.close();
      }

      for (final s in list) {
        subs.add(s.listen(
          multi.add,
          onError: multi.addError,
          onDone: onDone,
          cancelOnError: false,
        ));
      }
      multi.onCancel = () async {
        for (final sub in subs) {
          await sub.cancel();
        }
      };
    }, isBroadcast: true);
  }

  /// Combines latest values from streams and emits with [combiner]
  /// once all streams have produced at least one value.
  static Stream<R> combineLatest<T, R>(
    Iterable<Stream<T>> streams,
    R Function(List<T> values) combiner,
  ) {
    final list = streams.toList(growable: false);
    return Stream<R>.multi((multi) {
      final n = list.length;
      if (n == 0) {
        multi.close();
        return;
      }
      final lastValues = List<T?>.filled(n, null);
      final hasValue = List<bool>.filled(n, false);
      var readyCount = 0;
      final subs = <StreamSubscription<T>>[];
      var doneCount = 0;

      void maybeEmit(int changedIndex, T value) {
        if (!hasValue[changedIndex]) {
          hasValue[changedIndex] = true;
          readyCount++;
        }
        lastValues[changedIndex] = value;
        if (readyCount == n) {
          // Safe cast because all are set when readyCount == n
          multi.add(combiner(List<T>.generate(n, (i) => lastValues[i] as T)));
        }
      }

      void onDone() {
        doneCount++;
        if (doneCount == n) multi.close();
      }

      for (var i = 0; i < n; i++) {
        final idx = i;
        subs.add(list[i].listen(
          (v) => maybeEmit(idx, v),
          onError: multi.addError,
          onDone: onDone,
          cancelOnError: false,
        ));
      }

      multi.onCancel = () async {
        for (final sub in subs) {
          await sub.cancel();
        }
      };
    }, isBroadcast: true);
  }
}

extension StreamDistinctUniqueExtension<T> on Stream<T> {
  /// Filters out any value that has ever been seen before on this stream.
  ///
  /// Unlike [Stream.distinct], which drops only consecutive duplicates,
  /// this method ensures global uniqueness across the entire stream.
  ///
  /// [maxCacheSize] limits the number of cached values to prevent memory leaks.
  /// When the limit is reached, oldest values are removed (LRU strategy).
  Stream<T> distinctUnique({
    bool Function(T a, T b)? equals,
    int maxCacheSize = 1000,
  }) {
    final eq = equals ?? (T a, T b) => a == b;
    final seen = <T>[];
    return where((event) {
      for (final v in seen) {
        if (eq(v, event)) return false;
      }
      seen.add(event);
      // Prevent memory leak by limiting cache size
      if (seen.length > maxCacheSize) {
        seen.removeAt(0);
      }
      return true;
    });
  }
}
