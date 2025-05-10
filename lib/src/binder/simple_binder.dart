import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:rxdart/subjects.dart';

class SimpleBinder<S extends BinderState> extends BasicBinder<S> {
  late BehaviorSubject<S> _uiStatePipe;
  S get state => _uiStatePipe.value;

  SimpleBinder({
    required super.context,
    required super.statePreprocessor,
    Widget? errorWidget,
    Widget? emptyDataWidget,
  })  : _uiStatePipe = BehaviorSubject.seeded(
          statePreprocessor(),
        ),
        super(
          errorWidget: errorWidget,
          emptyDataWidget: emptyDataWidget,
        );

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

  @override
  void emitUiState(S state) {
    _uiStatePipe.add(state);
  }

  @override
  void dispose() {
    _uiStatePipe.close();
  }
}
