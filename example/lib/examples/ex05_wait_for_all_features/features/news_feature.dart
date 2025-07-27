import 'dart:math';

import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/entities/news_entities.dart';

class NewsFeature extends Feature<NewsEvent, NewsState, NewsSideEffect> {
  // Add error simulation rate for demonstration
  final double errorRate;
  final Random _random = Random();

  NewsFeature({this.errorRate = 0.2}) : super(initialState: NewsState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(NewsEvent event) async {
    if (event is LoadNewsEvent) {
      await _loadNews();
    }
  }

  Future<void> _loadNews() async {
    emitState(state.copyWith(isLoading: true, error: null));

    // Simulate news loading delay (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    try {
      // Simulate random errors for demonstration
      if (_random.nextDouble() < errorRate) {
        throw Exception('Network timeout');
      }

      // Simulate data fetching
      final news = [
        'New version of Flutter FBI is now available!',
        'Study shows reactive patterns are popular among developers',
        'Encapsulating Side Effects inside Binder makes code cleaner',
        'shouldWaitForAllFeatures parameter ensures data synchronization',
      ];

      emitState(state.copyWith(
        isLoading: false,
        news: news,
        error: null,
      ));
    } catch (e) {
      final errorMsg = 'Failed to load news: $e';
      emitState(state.copyWith(
        isLoading: false,
        error: errorMsg,
      ));
      emitSideEffect(NewsErrorEffect(errorMsg));
    }
  }
}
