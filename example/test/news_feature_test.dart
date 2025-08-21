import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/features/news_feature.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/entities/news_entities.dart';

void main() {
  featureTest<NewsEvent, NewsState, NewsSideEffect>(
    'NewsFeature load news success',
    build: () => NewsFeature(errorRate: 0.0),
    act: (feature) => feature.add(LoadNewsEvent()),
    expect: () => [
      isA<NewsState>().having((s) => s.isLoading, 'isLoading', true),
      isA<NewsState>().having((s) => s.news, 'news', isNotEmpty),
    ],
  );

  featureTest<NewsEvent, NewsState, NewsSideEffect>(
    'NewsFeature error path - states',
    build: () => NewsFeature(errorRate: 1.0),
    act: (feature) => feature.add(LoadNewsEvent()),
    expect: () => [
      isA<NewsState>().having((s) => s.isLoading, 'isLoading', true),
      isA<NewsState>().having((s) => s.error, 'error', isNotNull),
    ],
  );

  featureTest<NewsEvent, NewsState, NewsSideEffect>(
    'NewsFeature error path - side effects',
    build: () => NewsFeature(errorRate: 1.0),
    act: (feature) => feature.add(LoadNewsEvent()),
    // removed wait
    expectSideEffects: () => [isA<NewsErrorEffect>().having((e) => e.message, 'message', isNotNull)],
  );
}
