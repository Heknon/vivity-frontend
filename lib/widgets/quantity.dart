import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  const Quantity({
    Key? key,
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
    this.id
  }) : super(key: key);

  @override
  _QuantityState createState() => _QuantityState();
}

class _QuantityState extends State<Quantity> {
  late QuantityController _controller;
  late int currentQuantity;
  late int min;
  late int max;

  @override
  void initState() {
    super.initState();

    currentQuantity = widget.initialCount;
    min = widget.min;
    max = widget.max;

    _controller = widget.controller ?? QuantityController();
    _controller.setState(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.color),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      width: 90,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildIcon(Icons.remove, false),
          Text(currentQuantity.toStringAsFixed(0)),
          buildIcon(Icons.add, true),
        ],
      ),
    );
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
        ),
      ),
    );
  }

  void handleTap(bool increment) {
    if (increment) {
      if (currentQuantity + 1 > max) {
        if (widget.maxFailSnackbar != null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(widget.maxFailSnackbar!);
        }
        return;
      }
      incrementQuantity();
      if (widget.onIncrement != null) widget.onIncrement!(_controller, widget.id);
      return;
    }

    if (currentQuantity - 1 < min) {
      if (widget.minFailSnackbar != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(widget.minFailSnackbar!);
      }
      if (widget.onDelete != null) widget.onDelete!(_controller, widget.id);
      return;
    }

    decrementQuantity();
    if (widget.onDecrement != null) widget.onDecrement!(_controller, widget.id);
  }

  void updateMax(int max) {
    setState(() {
      this.max = max;
    });
  }

  void updateMin(int min) {
    setState(() {
      this.min = min;
    });
  }

  void updateCurrentQuantity(int quantity) {
    setState(() {
      currentQuantity = quantity;
    });
  }

  void incrementQuantity() {
    setState(() {
      currentQuantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      currentQuantity--;
    });
  }
}

class QuantityController {
  late _QuantityState _state;

  int get quantity => _state.currentQuantity;

  void setState(_QuantityState state) {
    _state = state;
  }

  void updateMax(int max) {
    _state.updateMax(max);
  }

  void updateMin(int min) {
    _state.updateMin(min);
  }

  void updateCurrentQuantity(int quantity) {
    _state.updateCurrentQuantity(quantity);
  }

  void incrementQuantity() {
    _state.incrementQuantity();
  }

  void decrementQuantity() {
    _state.decrementQuantity();
  }
}
