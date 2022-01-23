import 'dart:collection';

import 'package:flutter/widgets.dart';

class FadeInWidget extends StatefulWidget {
  final FadeInController? controller;
  final Widget initialWidget;
  final Duration duration;

  FadeInWidget({
    required this.initialWidget,
    this.duration = const Duration(seconds: 1),
    this.controller,
  });

  @override
  _FadeInWidgetState createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  final Queue<Widget> _widgetQueue = Queue();
  late Widget _currentWidget;
  Widget? _nextWidget;

  late AnimationController _ac;
  late FadeInController _controller;

  @override
  void initState() {
    super.initState();

    _currentWidget = widget.initialWidget;

    _ac = AnimationController(vsync: this, duration: widget.duration);

    _ac.addListener(() {
      if (_ac.isCompleted) {
        if (_nextWidget != null) {
          setState(() {
            _currentWidget = _nextWidget!;
            _nextWidget = null;
          });
        }

        if (_widgetQueue.isNotEmpty) {
          dynamic tempNext = _widgetQueue.removeFirst();
          if (identical(_currentWidget, tempNext)) return;
          _nextWidget = tempNext;
          _ac.value = 0;
          _ac.forward();
        }
      }
    });

    _controller = widget.controller ?? FadeInController();
    _controller._setState(this);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return AnimatedBuilder(
          animation: _ac,
          builder: (ctx, child) {
            // print((_currentWidget as Text).style?.fontSize);
            if (_nextWidget == null) return _currentWidget;

            return Stack(
              alignment: Alignment.topRight,
              children: [
                Transform.translate(
                  offset: Offset(0, -_ac.value * constraints.maxHeight),
                  child: Opacity(
                    opacity: 1 - _ac.value,
                    child: _currentWidget,
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, (-_ac.value * constraints.maxHeight) + constraints.maxHeight),
                  child: Opacity(
                    opacity: _ac.value,
                    child: _nextWidget!,
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  void pushWidgetToAnimation(Widget widget) {
    if (_ac.isAnimating) {
      return _widgetQueue.add(widget);
    }

    _nextWidget = widget;
    _ac.value = 0;
    _ac.forward();
  }

  void swapCurrentAnimatedWidget(Widget widget, bool clearQueue) {
    if (clearQueue) _widgetQueue.clear();
    _nextWidget = widget;
    if (_ac.isAnimating) return;

    _ac.value = 0;
    _ac.forward();
  }

  void gracefullySwapCurrentAnimatedWidget(Widget widget, bool clearQueue, double threshold) {
    if (clearQueue) _widgetQueue.clear();
    if (_ac.value > threshold && _nextWidget != null) {
      _currentWidget = _nextWidget!;
    }

    _nextWidget = widget;
    _ac.value = 0;
    _ac.forward();
  }

  void swapCurrentWidget(Widget widget) {
    setState(() {
      print((widget as Text).style?.fontSize);
      _currentWidget = widget;
    });
  }
}

class FadeInController {
  late _FadeInWidgetState _state;

  void _setState(_FadeInWidgetState state) {
    _state = state;
  }

  void pushWidgetToAnimation(Widget widget) {
    _state.pushWidgetToAnimation(widget);
  }

  /// Aggressively swaps current widget in animation. This will either start a new animation or swap current
  void swapCurrentAnimatedWidget(Widget widget, {bool clearQueue = true}) {
    _state.swapCurrentAnimatedWidget(widget, clearQueue);
  }

  /// Starts a new animation with a specific widget.
  /// If a widget is currently being animated and passed 'threshold' it will be the widget animated out
  void gracefullySwapCurrentAnimatedWidget(Widget widget, {bool clearQueue = true, double threshold = 0.0}) {
    _state.gracefullySwapCurrentAnimatedWidget(widget, clearQueue, threshold);
  }

  void swapCurrentWidget(Widget widget) {
    _state.swapCurrentWidget(widget);
  }
}
