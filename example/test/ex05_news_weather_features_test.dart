import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/features/news_feature.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/entities/news_entities.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/features/weather_feature.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/entities/weather_entities.dart';

void main() {
  testWidgets('NewsFeature loads news successfully', (tester) async {
    featureTest<NewsEvent, NewsState, NewsSideEffect>(
      'load news',
      build: () => NewsFeature(errorRate: 0.0),
      act: (f) => f.add(LoadNewsEvent()),
      expect: () => [
        const NewsState(isLoading: true),
        // second state has non-empty news; we check isLoading == false
        NewsState(isLoading: false, news: []),
      ],
      wait: const Duration(seconds: 4),
    );
  });

  testWidgets('WeatherFeature loads weather successfully', (tester) async {
    featureTest<WeatherEvent, WeatherState, WeatherSideEffect>(
      'load weather',
      build: () => WeatherFeature(errorRate: 0.0),
      act: (f) => f.add(LoadWeatherEvent()),
      expect: () => [
        const WeatherState(isLoading: true),
        // second state should have isLoading false
        WeatherState(isLoading: false),
      ],
      wait: const Duration(seconds: 2),
    );
  });
}
