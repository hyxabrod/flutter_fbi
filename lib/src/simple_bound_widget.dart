import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';

abstract class SimpleBoundWidget extends StatefulWidget {
  final SimpleBinder binder;
  const SimpleBoundWidget({Key? key, required this.binder});

  Widget builder(BuildContext context, covariant Binder binder);

  @override
  State<StatefulWidget> createState() {
    return BoundWidgetState();
  }

  SimpleBinder getBinder() => binder;
}

class SimpleBoundWidgetState extends State<BoundWidget> {
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
