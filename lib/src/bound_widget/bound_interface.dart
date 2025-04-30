import 'package:flutter_fbi/src/binder/binder_interface.dart';

abstract interface class IBoundWidget<B extends BasicBinder> {
  B getBinder();
}