import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';
import 'package:flutter_fbi/src/binder/binder_interface.dart';
import 'package:flutter_fbi/src/bound_widget/bound_interface.dart';

abstract class SimpleBoundWidget<B extends BasicBinder> extends StatefulWidget implements IBoundWidget<B> {
  final B binder;
  const SimpleBoundWidget({Key? key, required this.binder});

  Widget builder(BuildContext context, B binder);

  @override
  State<StatefulWidget> createState() {
    return _SimpleBoundWidgetState<B>();
  }

  B getBinder() => binder;
}

class _SimpleBoundWidgetState<B extends BasicBinder> extends State<SimpleBoundWidget> {
  _SimpleBoundWidgetState();

  @override
  Widget build(BuildContext context) {
    return BinderProvider<B>(
      binder: widget.binder as B,
      child: widget.builder(context, widget.binder),
    );
  }

  @override
  void dispose() {
    widget.binder.dispose();
    super.dispose();
  }
}
