import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

class Quantity extends StatefulWidget {
  final int initialCount;
  final int min;
  final int max;
  final Color color;
  final SnackBar? maxFailSnackbar;
  final SnackBar? minFailSnackbar;
  final QuantityController? controller;
  final int? id;
  final void Function(QuantityController, int?)? onDelete;
  final void Function(QuantityController, int?)? onIncrement;
  final void Function(QuantityController, int?)? onDecrement;

  const Quantity(
      {Key? key,
      this.initialCount = 1,
      this.min = 1,
      this.max = 10,
      this.controller,
      this.color = Colors.white,
      this.maxFailSnackbar = const SnackBar(
        content: Text("Can't buy more"),
      ),
      this.minFailSnackbar,
      this.onDelete,
      this.onIncrement,
      this.onDecrement,
      this.id})
      : super(key: key);

  @override
  _QuantityState createState() => _QuantityState();
}

class _QuantityState extends State<Quantity> {
  late QuantityController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? QuantityController();
    _controller.init(widget.initialCount, widget.min, widget.max);

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: widget.color),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildIcon(Icons.remove, false),
            Text(_controller.quantity.toStringAsFixed(0), style: TextStyle(fontSize: 9.5.sp, color: widget.color)),
            buildIcon(Icons.add, true),
          ],
        ),
      );
    });
  }

  Expanded buildIcon(IconData icon, bool increment) {
    return Expanded(
      flex: 1,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        onTap: () => handleTap(increment),
        child: Icon(
          icon,
          color: widget.color,
          size: 16.sp,
        ),
      ),
    );
  }

  void handleTap(bool increment) {
    if (increment) {
      if (_controller.quantity + 1 > _controller.max) {
        if (widget.maxFailSnackbar != null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(widget.maxFailSnackbar!);
        }
        return;
      }
      _controller.incrementQuantity();
      if (widget.onIncrement != null) widget.onIncrement!(_controller, widget.id);
      return;
    }

    if (_controller.quantity - 1 < _controller.min) {
      if (widget.minFailSnackbar != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(widget.minFailSnackbar!);
      }
      if (widget.onDelete != null) widget.onDelete!(_controller, widget.id);
      return;
    }

    _controller.decrementQuantity();
    if (widget.onDecrement != null) widget.onDecrement!(_controller, widget.id);
  }
}

class QuantityController extends ChangeNotifier {
  late int _quantity;
  late int _min;
  late int _max;

  int get min => _min;

  int get max => _max;

  int get quantity => _quantity;

  void init(int initialQuantity, int min, int max) {
    _quantity = initialQuantity;
    _min = min;
    _max = max;
  }

  void updateMax(int max) {
    _max = max;
    notifyListeners();
  }

  void updateMin(int min) {
    _min = min;
    notifyListeners();
  }

  void updateCurrentQuantity(int quantity) {
    _quantity = quantity;
    notifyListeners();
  }

  void incrementQuantity() {
    _quantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    _quantity--;
    notifyListeners();
  }
}
