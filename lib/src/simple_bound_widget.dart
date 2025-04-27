import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/flutter_fbi.dart';

abstract class SimpleBoundWidget extends StatefulWidget {
  final SimpleBinder binder;
  const SimpleBoundWidget({Key? key, required this.binder});

  Widget builder(BuildContext context, covariant SimpleBinder binder);

  @override
  State<StatefulWidget> createState() {
    return SimpleBoundWidgetState();
  }

  SimpleBinder getBinder() => binder;
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
