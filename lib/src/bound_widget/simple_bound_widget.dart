import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:flutter_fbi/src/bound_widget/bound_interface.dart';

abstract class SimpleBoundWidget<B extends BasicBinder> extends StatefulWidget implements IBoundWidget<B> {
  final B binder;
  const SimpleBoundWidget({Key? key, required this.binder});

  Widget builder(BuildContext context, B binder);

  @override
  State<StatefulWidget> createState() {
    return SimpleBoundWidgetState();
  }

  B getBinder() => binder;
}

class SimpleBoundWidgetState extends State<SimpleBoundWidget> {
  SimpleBoundWidgetState();

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.binder);
  }

  @override
  void dispose() {
    widget.binder.dispose();
    super.dispose();
  }
}
