import 'package:flutter_fbi/flutter_fbi.dart';

// Events
abstract class WeatherEvent extends UiEvent {}

class LoadWeatherEvent extends WeatherEvent {}

// State
class WeatherState extends FeatureState {
  final bool isLoading;
  final String currentTemperature;
  final String weatherCondition;
  final String? error;

  const WeatherState({
    this.isLoading = false,
    this.currentTemperature = '',
    this.weatherCondition = '',
    this.error,
  }) : super();

  WeatherState copyWith({
    bool? isLoading,
    String? currentTemperature,
    String? weatherCondition,
    String? error,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, currentTemperature, weatherCondition, error];
}

// Side Effect
abstract class WeatherSideEffect extends SideEffect {}

class WeatherErrorEffect extends WeatherSideEffect {
  final String message;
  WeatherErrorEffect(this.message);
}
