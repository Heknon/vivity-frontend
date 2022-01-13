import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivity/widgets/cart/cart_view.dart';
import 'package:vivity/widgets/util/side_tab.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Tween<double> _animationTween;
  late Animation<double> _animation;
  double heightOffsetFactor = 0.4;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _animationTween = Tween(begin: 0.0, end: 1.0);
    _animation = _animationTween.animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        double _sliderWidth = constraints.maxWidth * 0.1;
        Size sliderSize = Size(_sliderWidth, _sliderWidth * 0.9);

        ConstrainedBox cartViewBox = ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.65 - sliderSize.height,
            maxWidth: constraints.maxWidth - _sliderWidth * 1.5,
          ),
          child: const CartView(),
        );

        return AnimatedBuilder(
          animation: _animation,
          builder: (ctx, staticWidget) => Transform.translate(
            offset: Offset(-_animation.value * cartViewBox.constraints.maxWidth, 0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -cartViewBox.constraints.maxWidth,
                  top: constraints.maxHeight * heightOffsetFactor - cartViewBox.constraints.maxHeight / 2 - sliderSize.height / 2,
                  child: cartViewBox,
                ),
                buildSideTabGestureDetection(sliderSize, constraints),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSideTabGestureDetection(Size sliderSize, BoxConstraints constraints) {
    SvgPicture icon = SvgPicture.asset(
      "assets/icons/shopping_cart_go.svg",
      width: sliderSize.width * 0.5,
      height: sliderSize.height * 0.65,
    );

    return Positioned(
      right: 0,
      top: constraints.maxHeight * heightOffsetFactor - sliderSize.height,
      child: GestureDetector(
        onTap: toggle,
        onHorizontalDragStart: (details) => _onHorizontalDragStart(details, sliderSize, constraints),
        onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, constraints),
        onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, constraints),
        child: SideTab(sliderSize: sliderSize, icon: icon),
      ),
    );
  }

  void toggle() {
    if (_animationController.isCompleted) {
      _animation = _animationTween.animate(CurvedAnimation(parent: _animationController, curve: Curves.bounceIn));
      _animationController.reverse();
    } else {
      _animation = _animationTween.animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart));
      _animationController.forward();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details, Size sliderSize, BoxConstraints viewConstraints) {
    _animation = _animationTween.animate(_animationController);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    _animationController.value -= details.primaryDelta! / constraints.maxWidth;
  }

  void _onHorizontalDragEnd(DragEndDetails details, BoxConstraints constraints) {
    double _kMinFlingVelocity = 365.0;

    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }

    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx / constraints.maxWidth;

      _animationController.fling(velocity: -visualVelocity);
    } else if (_animationController.value < 0.5) {
      close();
    } else {
      open();
    }

    setState(() {});
  }

  void open() {
    _animationController.forward();
  }

  void close() {
    _animationController.reverse();
  }
}
