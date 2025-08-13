import 'package:flutter_fbi/flutter_fbi.dart';

// Events
abstract class CounterEvent extends UiEvent {}

class IncrementEvent extends CounterEvent {}

class DecrementEvent extends CounterEvent {}

class ResetEvent extends CounterEvent {}

// State
class CounterState extends FeatureState {
  final int count;

  const CounterState({this.count = 0});

  CounterState copyWith({int? count}) {
    return CounterState(
      count: count ?? this.count,
    );
  }

  @override
  List<Object?> get props => [count];
}

// UI State
class CounterUiState extends BinderState {
  final int count;
  final String countText;
  final bool canDecrement;

  const CounterUiState({
    required this.count,
    required this.countText,
    required this.canDecrement,
  });

  @override
  List<Object?> get props => [count, countText, canDecrement];
}
