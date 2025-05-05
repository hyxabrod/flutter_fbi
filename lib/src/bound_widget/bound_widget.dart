import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:flutter_fbi/src/bound_widget/bound_interface.dart';

abstract class BoundWidget<B extends BasicBinder> extends StatefulWidget implements IBoundWidget<B> {
  final B binder;
  const BoundWidget({Key? key, required this.binder});

  Widget builder(BuildContext context, B binder);

  @override
  State<StatefulWidget> createState() {
    return BoundWidgetState();
  }

  B getBinder() => binder;
}

class BoundWidgetState extends State<BoundWidget> {
  BoundWidgetState();

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
