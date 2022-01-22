import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vivity/features/search_filter/filter_bar.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';

/// Responsible for the bar which allows Search, filter and sort.
class WidgetSwapper extends StatefulWidget {
  final WidgetSwapperController? filterViewController;
  final Widget bar;
  final Widget sideBar;

  const WidgetSwapper({Key? key, this.filterViewController, required this.bar, required this.sideBar}) : super(key: key);

  @override
  _WidgetSwapperState createState() => _WidgetSwapperState();
}

class _WidgetSwapperState extends State<WidgetSwapper> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _animation;
  late WidgetSwapperController _controller;

  bool _isBarOpen = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.filterViewController!;
    _controller._setState(this);

    _ac = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animation = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (ctx, child) {
          if (_ac.isCompleted) return widget.bar;
          if (_ac.isDismissed) return widget.sideBar;

          Widget bottomWidget = _isBarOpen ? widget.sideBar : widget.bar;
          Widget topWidget = _isBarOpen ? widget.bar : widget.sideBar;

          return Stack(
            alignment: Alignment.topRight,
            fit: StackFit.passthrough,
            children: [
              SizedBox(
                width: constraints.minWidth + _ac.value * constraints.maxWidth, // 50 -> 300
                height: constraints.maxHeight - _ac.value * (constraints.maxHeight - constraints.minHeight), // 100 -> 50
                child: Opacity(opacity: _isBarOpen ? 1 - _ac.value : _ac.value, child: bottomWidget),
              ),
              SizedBox(
                width: constraints.minWidth + _ac.value * constraints.maxWidth, // 50 -> 300
                height: constraints.maxHeight - _ac.value * (constraints.maxHeight - constraints.minHeight), // 100 -> 50
                child: Opacity(opacity: _isBarOpen ? _ac.value : 1 - _ac.value, child: topWidget),
              ),
            ],
          );
        },
      );
    });
  }

  void open() {
    _ac.forward().whenComplete(() {
      setState(() {
        _isBarOpen = true;
      });
    });
  }

  void close() {
    _ac.reverse().whenComplete(() {
      setState(() {
        _isBarOpen = false;
      });
    });
  }

  void toggle() {
    _isBarOpen ? close() : open();
  }
}

class WidgetSwapperController {
  _WidgetSwapperState? state;

  void _setState(_WidgetSwapperState state) {
    this.state = state;
  }

  bool get isBarOpen => state!._isBarOpen;

  void open() {
    state!.open();
  }

  void close() {
    state!.close();
  }

  void toggle() {
    state!.toggle();
  }
}
