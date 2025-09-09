import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:flutter_fbi/src/utils/behavior_subject.dart';

/// A basic implementation of a Binder that follows a simple binding pattern.
///
/// Unlike [FeatureBinder] and [MultiFeatureBinder] which require feature classes
/// for state management, the [SimpleBinder] operates independently and provides
/// a straightforward way to manage UI state without feature dependencies.
///
/// This binder is ideal for simple scenarios where feature-based architecture
/// would be overengineering, such as form state management or local UI states.
///
/// Type Parameters:
/// * [S] - The type of state this binder manages, must extend [BinderState]
class SimpleBinder<S extends BinderState> extends BasicBinder<S> {
  late BehaviorSubject<S> _uiStatePipe;
  S get state => _uiStatePipe.value;

  SimpleBinder({
    required super.context,
    required super.uiStatePreprocessor,
    Widget? errorWidget,
    Widget? emptyDataWidget,
  })  : _uiStatePipe = BehaviorSubject.seeded(
          uiStatePreprocessor(),
        ),
        super(
          errorWidget: errorWidget,
          emptyDataWidget: emptyDataWidget,
        );

  @override
  Stream<S> getStateStream() => _uiStatePipe.stream.distinct();

  @override
  void emitUiState(S state) {
    _uiStatePipe.add(state);
  }

  @override
  void dispose() {
    _uiStatePipe.close();
  }
}
