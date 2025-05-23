import 'package:flutter/material.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/entities/news_entities.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/entities/weather_entities.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/features/news_feature.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/features/weather_feature.dart';

// Combined UI State
class DashboardWithWaitState extends BinderState {
  final bool isLoading;
  final bool isNewsLoading;
  final bool isWeatherLoading;
  final List<String> news;
  final String? temperature;
  final String? weatherCondition;
  final String? error;
  // Add timing information for demonstrating wait behavior
  final String? newsLoadTime;
  final String? weatherLoadTime;

  DashboardWithWaitState({
    required this.isLoading,
    required this.isNewsLoading,
    required this.isWeatherLoading,
    required this.news,
    this.temperature,
    this.weatherCondition,
    this.error,
    this.newsLoadTime,
    this.weatherLoadTime,
  });

  @override
  List<Object?> get props => [
        isLoading,
        isNewsLoading,
        isWeatherLoading,
        news,
        temperature,
        weatherCondition,
        error,
        newsLoadTime,
        weatherLoadTime,
      ];
}

class DashboardWithWaitBinder extends MultiFeatureBinder<DashboardWithWaitState> {
  late NewsFeature newsFeature;
  late WeatherFeature weatherFeature;
  // Store start times to calculate load duration
  final Map<String, DateTime> _loadStartTimes = {};

  DashboardWithWaitBinder({required BuildContext context, required List<Feature> features})
      : super(
          context: context,
          features: features,
          shouldWaitForAllFeatures: true, // When true: UI only updates after all features have emitted their states
          uiStatePreprocessor: () => DashboardWithWaitState(
            isLoading: true,
            isNewsLoading: true,
            isWeatherLoading: true,
            news: const [],
          ),
        ) {
    newsFeature = features.first as NewsFeature;
    weatherFeature = features.last as WeatherFeature;
    _setupSideEffectHandling();

    // Record start times and load data
    _loadStartTimes['news'] = DateTime.now();
    _loadStartTimes['weather'] = DateTime.now();
    newsFeature.add(LoadNewsEvent());
    weatherFeature.add(LoadWeatherEvent());
  }

  void _setupSideEffectHandling() {
    // Side effects are handled immediately, regardless of shouldWaitForAllFeatures
    bindSideEffect((effect) {
      if (effect is NewsErrorEffect || effect is WeatherErrorEffect) {
        String message = '';
        String source = '';

        if (effect is NewsErrorEffect) {
          message = effect.message;
          source = 'News';
        } else if (effect is WeatherErrorEffect) {
          message = effect.message;
          source = 'Weather';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$source Error: $message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String _calculateLoadTime(String feature) {
    final startTime = _loadStartTimes[feature];
    if (startTime == null) return '';
    final duration = DateTime.now().difference(startTime);
    return '${duration.inMilliseconds}ms';
  }

  void refreshData() {
    // Reset start times and trigger reloads
    _loadStartTimes['news'] = DateTime.now();
    _loadStartTimes['weather'] = DateTime.now();
    newsFeature.add(LoadNewsEvent());
    weatherFeature.add(LoadWeatherEvent());
  }

  @override
  DashboardWithWaitState uiStateTransformer(List<FeatureState> featureStates) {
    // This method is only called when all features have emitted states
    // due to shouldWaitForAllFeatures = true
    NewsState? newsState;
    WeatherState? weatherState;

    for (var state in featureStates) {
      if (state is NewsState) {
        newsState = state;
      } else if (state is WeatherState) {
        weatherState = state;
      }
    }

    final news = newsState ?? NewsState();
    final weather = weatherState ?? WeatherState();

    return DashboardWithWaitState(
      isLoading: news.isLoading || weather.isLoading,
      isNewsLoading: news.isLoading,
      isWeatherLoading: weather.isLoading,
      news: news.news,
      temperature: weather.currentTemperature,
      weatherCondition: weather.weatherCondition,
      error: news.error ?? weather.error,
      newsLoadTime: news.isLoading ? null : _calculateLoadTime('news'),
      weatherLoadTime: weather.isLoading ? null : _calculateLoadTime('weather'),
    );
  }
}
