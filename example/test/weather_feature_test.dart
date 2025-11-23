import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fbi_test/flutter_fbi_test.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/features/weather_feature.dart';
import 'package:flutter_fbi_example/examples/ex05_wait_for_all_features/entities/weather_entities.dart';

void main() {
  featureTest<WeatherEvent, WeatherState, WeatherSideEffect>(
    'WeatherFeature load success',
    build: () => WeatherFeature(errorRate: 0.0),
    act: (feature) => feature.add(LoadWeatherEvent()),
    expect: () => [
      isA<WeatherState>().having((s) => s.isLoading, 'isLoading', true),
      isA<WeatherState>().having((s) => s.currentTemperature, 'currentTemperature', isNotEmpty),
    ],
  );

  featureTest<WeatherEvent, WeatherState, WeatherSideEffect>(
    'WeatherFeature error emits error state and side effect',
    build: () => WeatherFeature(errorRate: 1.0),
    act: (feature) => feature.add(LoadWeatherEvent()),
    expect: () => [
      isA<WeatherState>().having((s) => s.isLoading, 'isLoading', true),
      isA<WeatherState>().having((s) => s.error, 'error', isNotNull),
    ],
  );

  featureTest<WeatherEvent, WeatherState, WeatherSideEffect>(
    'WeatherFeature error - side effects',
    build: () => WeatherFeature(errorRate: 1.0),
    act: (feature) => feature.add(LoadWeatherEvent()),
    expectSideEffects: () => [isA<WeatherErrorEffect>()],
  );
}
