import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/helpers/ui_helpers.dart';

class Quantity extends StatefulWidget {
  final Color color;
  final SnackBar? maxFailSnackbar;
  final SnackBar? minFailSnackbar;
  final QuantityController? controller;
  final bool deletable;
  final bool onlyQuantity;
  final void Function(QuantityController)? onDelete;
  final void Function(QuantityController)? onIncrement;
  final void Function(QuantityController)? onDecrement;

  const Quantity({
    Key? key,
    this.controller,
    this.color = Colors.white,
    this.maxFailSnackbar = const SnackBar(
      content: Text("Can't buy more"),
    ),
    this.minFailSnackbar,
    this.onDelete,
    this.onIncrement,
    this.onDecrement,
    this.deletable = false,
    this.onlyQuantity = false,
  }) : super(key: key);

  @override
  QuantityState createState() => QuantityState();
}

class QuantityState extends State<Quantity> {
  late QuantityController _controller;
  bool preparedToDelete = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? QuantityController();

    _controller.addListener(() {
      if (_controller.quantity > _controller.max) {
        if (widget.maxFailSnackbar != null && mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(widget.maxFailSnackbar!);
        }
        _controller.updateCurrentQuantity(_controller.max);
        return;
      } else if (_controller.quantity < _controller.min && !preparedToDelete) {
        if (widget.minFailSnackbar != null && mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(widget.minFailSnackbar!);
        }
        _controller.updateCurrentQuantity(_controller.min);
        return;
      }

      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    // _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        print('rendering quantity ${_controller.quantity} - ${_controller.hashCode} - ${_controller.mounted}');
        Text text = Text(_controller.quantity.toStringAsFixed(0), style: TextStyle(fontSize: 9.5.sp, color: widget.color));
        Size textSize = getTextSize(text);
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: widget.color),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          width: !widget.onlyQuantity ? constraints.maxWidth : max(constraints.maxHeight, textSize.width + 10.sp),
          height: constraints.maxHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              !widget.onlyQuantity ? buildIcon(Icons.remove, false) : Container(),
              text,
              !widget.onlyQuantity ? buildIcon(Icons.add, true) : Container(),
            ],
          ),
        );
      },
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
      if (widget.onIncrement != null) widget.onIncrement!(_controller);
      preparedToDelete = false;
      return;
    }

    if (_controller.quantity - 1 < _controller.min) {
      if (widget.minFailSnackbar != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(widget.minFailSnackbar!);
      }

      if (widget.deletable && _controller.quantity == _controller.min) {
        if (preparedToDelete) {
          _controller.updateCurrentQuantity(0);
          if (widget.onDelete != null) widget.onDelete!(_controller);
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Press again to delete')));
        preparedToDelete = true;
      }
      return;
    }

    _controller.decrementQuantity();
    if (widget.onDecrement != null) widget.onDecrement!(_controller);
  }
}

class QuantityController extends ChangeNotifier {
  int quantity;
  int min;
  int max;

  bool mounted = false;

  QuantityController({this.quantity = 1, this.min = 1, this.max = 10}) {
    print('created controller with quantity ${quantity} - ${hashCode}');
    this.mounted = true;
  }

  void updateMax(int max) {
    this.max = max;
    notifyListeners();
  }

  void updateMin(int min) {
    this.min = min;
    notifyListeners();
  }

  void updateCurrentQuantity(int quantity) {
    this.quantity = quantity;
    notifyListeners();
  }

  void incrementQuantity() {
    this.quantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    this.quantity--;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();

    mounted = false;
  }

  @override
  String toString() {
    return 'QuantityController{quantity: $quantity, hash: $hashCode}';
  }
}
