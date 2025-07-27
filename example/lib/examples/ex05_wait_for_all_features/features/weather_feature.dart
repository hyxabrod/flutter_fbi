import 'dart:math';

import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/entities/weather_entities.dart';

class WeatherFeature extends Feature<WeatherEvent, WeatherState, WeatherSideEffect> {
  // Add error simulation rate for demonstration
  final double errorRate;
  final Random _random = Random();

  // Sample weather conditions for demonstration
  final List<Map<String, String>> _conditions = [
    {'temp': '24°C', 'condition': 'Sunny'},
    {'temp': '18°C', 'condition': 'Partly Cloudy'},
    {'temp': '15°C', 'condition': 'Cloudy'},
    {'temp': '20°C', 'condition': 'Light Rain'},
  ];

  WeatherFeature({this.errorRate = 0.2}) : super(initialState: WeatherState()) {
    onEvent(_handleEvent);
  }

  void _handleEvent(WeatherEvent event) async {
    if (event is LoadWeatherEvent) {
      await _loadWeather();
    }
  }

  Future<void> _loadWeather() async {
    emitState(state.copyWith(isLoading: true, error: null));

    // Simulate weather loading delay (1 seconds)
    // This delay is longer than news to demonstrate waiting for all features
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Simulate random errors for demonstration
      if (_random.nextDouble() < errorRate) {
        throw Exception('API request failed');
      }

      // Simulate weather data fetching with random conditions
      final weather = _conditions[_random.nextInt(_conditions.length)];

      emitState(state.copyWith(
        isLoading: false,
        currentTemperature: weather['temp'],
        weatherCondition: weather['condition'],
        error: null,
      ));
    } catch (e) {
      final errorMsg = 'Failed to load weather data: $e';
      emitState(state.copyWith(
        isLoading: false,
        error: errorMsg,
      ));
      emitSideEffect(WeatherErrorEffect(errorMsg));
    }
  }
}
