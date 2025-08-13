import 'package:flutter_fbi/flutter_fbi.dart';

// Events
abstract class ConcurrentEvent extends UiEvent {}

class SlowIncEvent extends ConcurrentEvent {}

class FastPingEvent extends ConcurrentEvent {}

// State
class ConcurrentState extends FeatureState {
  final int value;
  const ConcurrentState(this.value);
  @override
  List<Object?> get props => [value];
}

// Side Effect
class ConcurrentFx extends SideEffect {
  final String msg;
  ConcurrentFx(this.msg);
}
