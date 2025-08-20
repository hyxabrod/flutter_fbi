import 'package:flutter_fbi/flutter_fbi.dart';
import 'concurrent_entities.dart';

class ConcurrentFeature
    extends Feature<ConcurrentEvent, ConcurrentState, ConcurrentFx> {
  ConcurrentFeature() : super(initialState: const ConcurrentState(0)) {
    onEvent(_handleEvent);
  }

  void _handleEvent(ConcurrentEvent event) async {
    switch (event) {
      case SlowIncEvent():
        await Future<void>.delayed(const Duration(milliseconds: 800));
        emitState(ConcurrentState(state.value + 1));
        emitSideEffect(ConcurrentFx('slow-inc-done'));
      case FastPingEvent():
        emitSideEffect(ConcurrentFx('fast'));
    }
  }
}
