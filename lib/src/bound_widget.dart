import 'package:flutter/widgets.dart';
import 'package:flutter_fbi/src/feature_binder.dart';

abstract class BaseBoundWidget extends StatefulWidget {
  final Binder binder;

  const BaseBoundWidget({Key? key, required this.binder}) : super(key: key);

  Widget builder(BuildContext context, covariant Binder binder);

  @override
  State<StatefulWidget> createState() {
    return BoundWidgetState();
  }
}

abstract class BoundWidget extends BaseBoundWidget {
  const BoundWidget({Key? key, required Binder binder}) : super(key: key, binder: binder);

  @override
  State<StatefulWidget> createState() {
    return BoundWidgetState();
  }

  Binder getBinder() => binder;
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
