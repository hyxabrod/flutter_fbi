import 'package:flutter_fbi/flutter_fbi.dart';

class SimpleCounterState extends BinderState {
  final int count;

  SimpleCounterState({this.count = 0});

  SimpleCounterState copyWith({int? count}) {
    return SimpleCounterState(
      count: count ?? this.count,
    );
  }

  @override
  List<Object?> get props => [count];
}
