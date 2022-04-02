/*
Name: Akshath Jain
Date: 3/18/2019 - 4/2/2020
Purpose: Defines the sliding_up_panel widget
Copyright: © 2020, Akshath Jain. All rights reserved.
Licensing: More information can be found here: https://github.com/akshathjain/sliding_up_panel/blob/master/LICENSE
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/physics.dart';

enum SlideDirection {
  UP,
  DOWN,
  LEFT,
  RIGHT,
}

enum ClickType { PanelClick, ContentClick }

enum PanelState { OPEN, CLOSED }

class SlidingUpPanel extends StatefulWidget {
  /// The Widget that slides into view. When the
  /// panel is collapsed and if [collapsed] is null,
  /// then top portion of this Widget will be displayed;
  /// otherwise, [collapsed] will be displayed overtop
  /// of this Widget. If [panel] and [contentBuilder] are both non-null,
  /// [panel] will be used.
  final Widget panel;

  /// WARNING: This feature is still in beta and is subject to change without
  /// notice. Stability is not gauranteed. Provides a [ScrollController] and
  /// [ScrollPhysics] to attach to a scrollable object in the panel that links
  /// the panel position with the scroll position. Useful for implementing an
  /// infinite scroll behavior. If [panel] and [contentBuilder] are both non-null,
  /// [panel] will be used.
  final Widget Function(ScrollController sc) contentBuilder;

  /// The height of the sliding panel when fully collapsed.
  final double panelSize;

  /// The height of the sliding panel when fully open.
  final double contentSize;

  /// A point between [panelSize] and [contentSize] that the panel snaps to
  /// while animating. A fast swipe on the panel will disregard this point
  /// and go directly to the open/close position. This value is represented as a
  /// percentage of the total animation distance ([contentSize] - [panelSize]),
  /// so it must be between 0.0 and 1.0, exclusive.
  final double? snapPoint;

  /// A border to draw around the sliding panel sheet.
  final Border? border;

  /// If non-null, the corners of the sliding panel sheet are rounded by this [BorderRadiusGeometry].
  final BorderRadiusGeometry? borderRadius;

  /// A list of shadows cast behind the sliding panel sheet.
  final List<BoxShadow>? boxShadow;

  /// The color to fill the background of the sliding panel sheet.
  final Color color;

  /// The amount to inset the children of the sliding panel sheet.
  final EdgeInsetsGeometry? padding;

  /// Empty space surrounding the sliding panel sheet.
  final EdgeInsetsGeometry? margin;

  /// Set to false to disable the panel from snapping open or closed.
  final bool panelSnapping;

  /// If non-null, this can be used to control the state of the panel.
  final PanelController? controller;

  /// If non-null, shows a darkening shadow over the [body] as the panel slides open.
  final bool backdropEnabled;

  /// Shows a darkening shadow of this [Color] over the [body] as the panel slides open.
  final Color backdropColor;

  /// The opacity of the backdrop when the panel is fully open.
  /// This value can range from 0.0 to 1.0 where 0.0 is completely transparent
  /// and 1.0 is completely opaque.
  final double backdropOpacity;

  /// Flag that indicates whether or not tapping the
  /// backdrop closes the panel. Defaults to true.
  final bool backdropTapClosesPanel;

  /// If non-null, this callback
  /// is called as the panel slides around with the
  /// current position of the panel. The position is a double
  /// between 0.0 and 1.0 where 0.0 is fully collapsed and 1.0 is fully open.
  final void Function(double position)? onPanelSlide;

  /// If non-null, this callback is called when the
  /// panel is fully opened
  final VoidCallback? onPanelOpened;

  /// If non-null, this callback is called when the panel
  /// is fully collapsed.
  final VoidCallback? onPanelClosed;

  final void Function(ClickType)? onPanelClicked;

  /// Either SlideDirection.UP or SlideDirection.DOWN. Indicates which way
  /// the panel should slide. Defaults to UP. If set to DOWN, the panel attaches
  /// itself to the top of the screen and is fully opened when the user swipes
  /// down on the panel.
  final SlideDirection slideDirection;

  /// The default state of the panel; either PanelState.OPEN or PanelState.CLOSED.
  /// This value defaults to PanelState.CLOSED which indicates that the panel is
  /// in the closed position and must be opened. PanelState.OPEN indicates that
  /// by default the Panel is open and must be swiped closed by the user.
  final PanelState defaultPanelState;

  final Duration departDuration;

  final Duration? returnDuration;

  final Curve? departCurve;

  final Curve? returnCurve;

  final bool gestureDetectOnlyPanel;

  final Offset? defaultOffset;

  SlidingUpPanel({
    Key? key,
    required this.panel,
    required this.contentBuilder,
    this.panelSize = 100.0,
    this.contentSize = 500.0,
    this.snapPoint,
    this.border,
    this.borderRadius,
    this.boxShadow = const <BoxShadow>[
      BoxShadow(
        blurRadius: 8.0,
        color: Color.fromRGBO(0, 0, 0, 0.25),
      )
    ],
    this.color = Colors.white,
    this.padding,
    this.margin,
    this.panelSnapping = true,
    this.controller,
    this.backdropEnabled = false,
    this.backdropColor = Colors.black,
    this.backdropOpacity = 0.5,
    this.backdropTapClosesPanel = true,
    this.onPanelSlide,
    this.onPanelOpened,
    this.onPanelClosed,
    this.onPanelClicked,
    this.slideDirection = SlideDirection.UP,
    this.defaultPanelState = PanelState.CLOSED,
    this.departCurve,
    this.returnCurve,
    this.departDuration = const Duration(milliseconds: 300),
    this.returnDuration,
    this.gestureDetectOnlyPanel = false,
    this.defaultOffset,
  })  : assert(panel != null || contentBuilder != null),
        assert(0 <= backdropOpacity && backdropOpacity <= 1.0),
        assert(snapPoint == null || 0 < snapPoint && snapPoint < 1.0),
        super(key: key);

  @override
  _SlidingUpPanelState createState() => _SlidingUpPanelState();
}

class _SlidingUpPanelState extends State<SlidingUpPanel> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late ScrollController _sc;

  late Tween<double> _tween;
  late Animation<double> _animation;
  CurvedAnimation? _departCurve;
  CurvedAnimation? _returnCurve;
  late bool _isUnifiedCurve;

  bool _scrollingEnabled = false;
  VelocityTracker _vt = new VelocityTracker.withKind(PointerDeviceKind.touch);

  bool _isPanelVisible = true;

  @override
  void initState() {
    super.initState();

    _isUnifiedCurve = widget.departCurve == widget.returnCurve && widget.departCurve != null; // if both equal and one not null -> both not null

    _ac = new AnimationController(
        vsync: this,
        duration: widget.departDuration,
        reverseDuration: widget.returnDuration,
        value: widget.defaultPanelState == PanelState.CLOSED ? 0.0 : 1.0 //set the default panel state (i.e. set initial value of _ac)
        )
      ..addListener(() {
        if (widget.onPanelSlide != null) widget.onPanelSlide!(_ac.value);

        if (widget.onPanelOpened != null && _ac.value == 1.0) widget.onPanelOpened!();

        if (widget.onPanelClosed != null && _ac.value == 0.0) widget.onPanelClosed!();
      });

    // prevent the panel content from being scrolled only if the widget is
    // draggable and panel scrolling is enabled
    _sc = new ScrollController();
    _scrollingEnabled = widget.gestureDetectOnlyPanel;
    _sc.addListener(() {
      if (!_scrollingEnabled) _sc.jumpTo(0);
    });

    widget.controller?._addState(this);
  }

  Alignment getAlignmentBasedSlideDirection(SlideDirection slideDirection) {
    switch (slideDirection) {
      case SlideDirection.UP:
        return Alignment.bottomCenter;
      case SlideDirection.DOWN:
        return Alignment.topCenter;
      case SlideDirection.RIGHT:
        return Alignment.centerLeft;
      case SlideDirection.LEFT:
        return Alignment.centerRight;
    }
  }

  double getOffsetBasedSlideDirection(Offset offset) {
    if (isHorizontalSlide) {
      return offset.dx;
    } else {
      return offset.dy;
    }
  }

  double getInsetBasedSlideDirection(EdgeInsetsGeometry insets) {
    if (isHorizontalSlide) {
      return insets.vertical;
    } else {
      return insets.horizontal;
    }
  }

  double adjustForSlideDirection(double number) {
    return isPositiveSlideDirection ? number : -number;
  }

  Offset getAnimatedOffsetBasedSlideDirection(double change) {
    switch (widget.slideDirection) {
      case SlideDirection.LEFT:
        return Offset(-change, 0);
      case SlideDirection.RIGHT:
        return Offset(change, 0);
      case SlideDirection.UP:
        return Offset(0, -change);
      case SlideDirection.DOWN:
        return Offset(0, change);
    }
  }

  bool get isVerticalSlide => widget.slideDirection == SlideDirection.UP || widget.slideDirection == SlideDirection.DOWN;

  bool get isHorizontalSlide => widget.slideDirection == SlideDirection.LEFT || widget.slideDirection == SlideDirection.RIGHT;

  bool get isPositiveSlideDirection => widget.slideDirection == SlideDirection.UP || widget.slideDirection == SlideDirection.LEFT;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Stack(
      alignment: getAlignmentBasedSlideDirection(widget.slideDirection),
      children: <Widget>[
        //the backdrop to overlay on the body
        !widget.backdropEnabled
            ? Container()
            : GestureDetector(
                onVerticalDragEnd: widget.backdropTapClosesPanel
                    ? (DragEndDetails dets) {
                        // only trigger a close if the drag is towards panel close position
                        if (adjustForSlideDirection(getOffsetBasedSlideDirection(dets.velocity.pixelsPerSecond)) > 0) _close();
                      }
                    : null,
                onTap: widget.backdropTapClosesPanel ? () => _close() : null,
                child: AnimatedBuilder(
                  animation: _ac,
                  builder: (context, _) {
                    return Container(
                      height: screenSize.height + 100,
                      width: screenSize.width,

                      //set color to null so that touch events pass through
                      //to the body when the panel is closed, otherwise,
                      //if a color exists, then touch events won't go through
                      color: _ac.value == 0.0 ? null : widget.backdropColor.withOpacity(widget.backdropOpacity * _ac.value),
                    );
                  },
                ),
              ),

        //the actual sliding part
        !_isPanelVisible
            ? Container()
            : !widget.gestureDetectOnlyPanel
                ? _gestureHandler(
                    child: AnimatedBuilder(
                      animation: _ac,
                      builder: (context, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            rewrapPositioned(
                              child: child,
                              builder: (ch) => Transform.translate(
                                offset: getAnimatedOffsetBasedSlideDirection(_ac.value * (widget.contentSize - widget.panelSize)),
                                child: GestureDetector(
                                  onTap: () => _onGestureTap(null),
                                  child: ch,
                                ),
                              ),
                            ),
                            rewrapPositioned(
                              child: widget.contentBuilder(_sc),
                              includeHeight: !isVerticalSlide,
                              includeWidth: !isHorizontalSlide,
                              builder: (ch) => Container(
                                height: isVerticalSlide ? _ac.value * (widget.contentSize - widget.panelSize) : null,
                                width: isHorizontalSlide ? _ac.value * (widget.contentSize - widget.panelSize) : null,
                                child: ch,
                              ),
                            ),
                          ],
                        );
                      },
                      child: widget.panel,
                    ),
                  )
                : AnimatedBuilder(
                    animation: _ac,
                    builder: (context, child) {
                      if (_isPanelClosed) {
                        return Transform.translate(
                          offset: getAnimatedOffsetBasedSlideDirection(-widget.contentSize),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              rewrapPositioned(
                                child: child,
                                builder: (ch) => Transform.translate(
                                  offset: getAnimatedOffsetBasedSlideDirection(widget.contentSize),
                                  child: _gestureHandler(child: ch),
                                ),
                              ),
                              rewrapPositioned(
                                child: widget.contentBuilder(_sc),
                                includeHeight: !isVerticalSlide,
                                includeWidth: !isHorizontalSlide,
                                builder: (ch) => Opacity(
                                  opacity: 1,
                                  child: ch,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (_isPanelOpen) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            rewrapPositioned(
                              child: child,
                              builder: (ch) => Transform.translate(
                                offset: getAnimatedOffsetBasedSlideDirection(widget.contentSize),
                                child: _gestureHandler(child: ch),
                              ),
                            ),
                            rewrapPositioned(
                              child: widget.contentBuilder(_sc),
                              includeHeight: !isVerticalSlide,
                              includeWidth: !isHorizontalSlide,
                              builder: (ch) => ch,
                            ),
                          ],
                        );
                      } else {
                        return Transform.translate(
                          offset: getAnimatedOffsetBasedSlideDirection(
                              _ac.value * (widget.contentSize) - widget.contentSize),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              rewrapPositioned(
                                child: child,
                                builder: (ch) => Transform.translate(
                                  offset: getAnimatedOffsetBasedSlideDirection(widget.contentSize),
                                  child: _gestureHandler(child: ch),
                                ),
                              ),
                              rewrapPositioned(
                                child: widget.contentBuilder(_sc),
                                includeHeight: !isVerticalSlide,
                                includeWidth: !isHorizontalSlide,
                                builder: (ch) => ch,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: widget.panel,
                  ),
      ],
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  /// Brings positioned widget up tree to avoid error.
  /// if widget has child of positioned it will be brought above widget and positioned child will become child of widget.
  Widget rewrapPositioned({
    required dynamic child,
    required Widget Function(dynamic child) builder,
    bool includeHeight = true,
    bool includeWidth = true,
    bool includeLeft = true,
    bool includeRight = true,
    bool includeTop = true,
    bool includeBottom = true,
  }) {
    if (child is! Positioned) {
      return builder(child);
    }

    return Positioned(
      height: includeHeight ? child.height : null,
      width: includeWidth ? child.width : null,
      top: includeTop ? child.top : null,
      bottom: includeBottom ? child.bottom : null,
      left: includeLeft ? child.left : null,
      right: includeRight ? child.right : null,
      child: builder(child.child),
    );
  }

  PointerEvent? prevDownPointerEvent = null;

  // returns a gesture detector if panel is used
  // and a listener if panelBuilder is used.
  // this is because the listener is designed only for use with linking the scrolling of
  // panels and using it for panels that don't want to linked scrolling yields odd results
  Widget _gestureHandler({required Widget child}) {
    return Listener(
      onPointerDown: (PointerDownEvent p) {
        prevDownPointerEvent = p;
        _vt.addPosition(p.timeStamp, p.position);
      },
      onPointerMove: (PointerMoveEvent p) {
        _vt.addPosition(p.timeStamp, p.position); // add current position for velocity tracking
        _onGestureSlide(p.delta);
      },
      onPointerUp: (PointerUpEvent p) {
        if (prevDownPointerEvent != null) {
          double distanceFromPrev =
              sqrt(pow(p.position.dx - prevDownPointerEvent!.position.dx, 2) + pow(p.position.dy - prevDownPointerEvent!.position.dy, 2));

          if (distanceFromPrev <= 20) _onGestureTap(prevDownPointerEvent!);
          prevDownPointerEvent = null;
        }

        _onGestureEnd(_vt.getVelocity());
      },
      child: child,
    );
  }

  void _onGestureTap(PointerEvent? p) {
    if (p == null || widget.gestureDetectOnlyPanel) toggle();
    if (widget.onPanelClicked != null)
      widget.onPanelClicked!(
        widget.gestureDetectOnlyPanel
            ? ClickType.PanelClick
            : p == null
                ? ClickType.PanelClick
                : ClickType.ContentClick,
      );
  }

  // handles the sliding gesture
  void _onGestureSlide(Offset axialChange) {
    // only slide the panel if scrolling is not enabled
    if (!_scrollingEnabled || widget.gestureDetectOnlyPanel) {
      if (isVerticalSlide) {
        _ac.value -= adjustForSlideDirection(axialChange.dy / (widget.contentSize + widget.panelSize));
      } else {
        _ac.value -= adjustForSlideDirection(axialChange.dx / (widget.contentSize + widget.panelSize));
      }
    }

    // if the panel is open and the user hasn't scrolled, we need to determine
    // whether to enable scrolling if the user swipes up, or disable closing and
    // begin to close the panel if the user swipes down
    if (_isPanelOpen && _sc.hasClients && _sc.offset <= 0 && !widget.gestureDetectOnlyPanel) {
      setState(() {
        if (axialChange.dy < 0) {
          _scrollingEnabled = true;
        } else {
          _scrollingEnabled = false;
        }
      });
    }
  }

  // handles when user stops sliding
  void _onGestureEnd(Velocity v) {
    double minFlingVelocity = 365.0;
    double kSnap = 8;

    //let the current animation finish before starting a new one
    if (_ac.isAnimating) return;

    // if scrolling is allowed and the panel is open, we don't want to close
    // the panel if they swipe up on the scrollable
    if (_isPanelOpen && _scrollingEnabled && isVerticalSlide) return;

    //check if the velocity is sufficient to constitute fling to end
    double axialPixelsPerSecond = getOffsetBasedSlideDirection(v.pixelsPerSecond);
    double visualVelocity = -axialPixelsPerSecond / (widget.contentSize);

    // reverse visual velocity to account for slide direction
    visualVelocity = adjustForSlideDirection(visualVelocity);

    // get minimum distances to figure out where the panel is at
    double d2Close = _ac.value;
    double d2Open = 1 - _ac.value;
    double d2Snap = ((widget.snapPoint ?? 3) - _ac.value).abs(); // large value if null results in not every being the min
    double minDistance = min(d2Close, min(d2Snap, d2Open));

    // check if velocity is sufficient for a fling
    if (axialPixelsPerSecond.abs() >= minFlingVelocity) {
      // snapPoint exists
      if (widget.panelSnapping && widget.snapPoint != null) {
        if (axialPixelsPerSecond.abs() >= kSnap * minFlingVelocity || minDistance == d2Snap)
          _ac.fling(velocity: visualVelocity);
        else
          _flingPanelToPosition(widget.snapPoint!, visualVelocity);

        // no snap point exists
      } else if (widget.panelSnapping) {
        _ac.fling(velocity: visualVelocity);

        // panel snapping disabled
      } else {
        _ac.animateTo(
          _ac.value + visualVelocity * 0.16,
          duration: Duration(milliseconds: 410),
          curve: Curves.decelerate,
        );
      }

      return;
    }

    // check if the controller is already halfway there
    if (widget.panelSnapping) {
      if (minDistance == d2Close) {
        _close();
      } else if (minDistance == d2Snap) {
        _flingPanelToPosition(widget.snapPoint!, visualVelocity);
      } else {
        _open();
      }
    }
  }

  void _flingPanelToPosition(double targetPos, double velocity) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: 500.0,
        ratio: 1.0,
      ),
      _ac.value,
      targetPos,
      velocity,
    );

    _ac.animateWith(simulation);
  }

  //---------------------------------
  //PanelController related functions
  //---------------------------------

  void toggle() {
    _isPanelOpen ? _close() : _open();
  }

  //close the panel
  Future<void> _close() async {
    await _ac.animateTo(0, duration: widget.returnDuration, curve: widget.returnCurve ?? Curves.decelerate);
  }

  //open the panel
  Future<void> _open() async {
    await _ac.animateTo(1, duration: widget.departDuration, curve: widget.departCurve ?? Curves.decelerate);
  }

  //hide the panel (completely offscreen)
  Future<void> _hide() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = false;
      });
    });
  }

  //show the panel (in collapsed mode)
  Future<void> _show() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = true;
      });
    });
  }

  //animate the panel position to value - must
  //be between 0.0 and 1.0
  Future<void> _animatePanelToPosition(double value, {Duration? duration, Curve curve = Curves.linear}) {
    assert(0.0 <= value && value <= 1.0);
    return _ac.animateTo(value, duration: duration, curve: curve);
  }

  //animate the panel position to the snap point
  //REQUIRES that widget.snapPoint != null
  Future<void> _animatePanelToSnapPoint({Duration? duration, Curve curve = Curves.linear}) {
    assert(widget.snapPoint != null);
    return _ac.animateTo(widget.snapPoint!, duration: duration, curve: curve);
  }

  //set the panel position to value - must
  //be between 0.0 and 1.0
  set _panelPosition(double value) {
    assert(0.0 <= value && value <= 1.0);
    _ac.value = value;
  }

  //get the current panel position
  //returns the % offset from collapsed state
  //as a decimal between 0.0 and 1.0
  double get _panelPosition => _ac.value;

  //returns whether or not
  //the panel is still animating
  bool get _isPanelAnimating => _ac.isAnimating;

  //returns whether or not the
  //panel is open
  bool get _isPanelOpen => _ac.value >= 0.99;

  //returns whether or not the
  //panel is closed
  bool get _isPanelClosed => _ac.value <= 0.01;

  //returns whether or not the
  //panel is shown/hidden
  bool get _isPanelShown => _isPanelVisible;
}

class PanelController {
  _SlidingUpPanelState? _panelState;

  void _addState(_SlidingUpPanelState panelState) {
    this._panelState = panelState;
  }

  /// Determine if the panelController is attached to an instance
  /// of the SlidingUpPanel (this property must return true before any other
  /// functions can be used)
  bool get isAttached => _panelState != null;

  /// Closes the sliding panel to its collapsed state (i.e. to the  minHeight)
  Future<void> close() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._close();
  }

  /// Opens the sliding panel fully
  /// (i.e. to the maxHeight)
  Future<void> open() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._open();
  }

  /// Hides the sliding panel (i.e. is invisible)
  Future<void> hide() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._hide();
  }

  /// Shows the sliding panel in its collapsed state
  /// (i.e. "un-hide" the sliding panel)
  Future<void> show() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._show();
  }

  /// Animates the panel position to the value.
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToPosition(double value, {Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    return _panelState!._animatePanelToPosition(value, duration: duration, curve: curve);
  }

  /// Animates the panel position to the snap point
  /// Requires that the SlidingUpPanel snapPoint property is not null
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToSnapPoint({Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(_panelState!.widget.snapPoint != null, "SlidingUpPanel snapPoint property must not be null");
    return _panelState!._animatePanelToSnapPoint(duration: duration, curve: curve);
  }

  /// Sets the panel position (without animation).
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  set panelPosition(double value) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    _panelState!._panelPosition = value;
  }

  /// Gets the current panel position.
  /// Returns the % offset from collapsed state
  /// to the open state
  /// as a decimal between 0.0 and 1.0
  /// where 0.0 is fully collapsed and
  /// 1.0 is full open.
  double get panelPosition {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._panelPosition;
  }

  /// Returns whether or not the panel is
  /// currently animating.
  bool get isPanelAnimating {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelAnimating;
  }

  /// Returns whether or not the
  /// panel is open.
  bool get isPanelOpen {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelOpen;
  }

  /// Returns whether or not the
  /// panel is closed.
  bool get isPanelClosed {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelClosed;
  }

  /// Returns whether or not the
  /// panel is shown/hidden.
  bool get isPanelShown {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelShown;
  }
}
