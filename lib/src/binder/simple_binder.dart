import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:rxdart/subjects.dart';

abstract class SimpleBinder<S extends BinderState> implements BasicBinder<S> {
  final BuildContext context;
  late BehaviorSubject<S> _uiStatePipe;

  S get state => _uiStatePipe.value;

  SimpleBinder({required this.context, required S initialState}) {
    _uiStatePipe = BehaviorSubject.seeded(initialState);
  }

  @override
  Widget bindState(BoundWidgetBuilder<S> builder) {
    return StreamBuilder<S>(
      stream: _uiStatePipe.stream.distinct(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox.shrink();
        } else {
          return builder(context, snapshot.data!);
        }
      },
    );
  }

  void emitUiState(S state) {
    _uiStatePipe.add(state);
  }

  @override
  void dispose() {
    _uiStatePipe.close();
  }
}
