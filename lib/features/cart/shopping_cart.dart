import 'package:advanced_panel/panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivity/features/cart/side_tab.dart';
import 'cart_view.dart';

class ShoppingCart extends StatefulWidget {
  final double heightOffsetFactor;

  ShoppingCart({Key? key, this.heightOffsetFactor = 0.4}) : super(key: key);

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  Widget? _cachedBody;
  Widget? _cachedCartView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        double _sliderWidth = constraints.maxWidth * 0.1;
        Size sliderSize = Size(_sliderWidth, _sliderWidth * 0.9);
        Size cartViewSize = Size(constraints.maxWidth - sliderSize.width * 1.5, constraints.maxHeight * 0.65 - sliderSize.height);
        SvgPicture icon = SvgPicture.asset(
          "assets/icons/shopping_cart_go.svg",
          width: sliderSize.width * 0.5,
          height: sliderSize.height * 0.65,
        );

        return SlidingUpPanel(
          slideDirection: SlideDirection.LEFT,
          panel: buildCartSliderButton(sliderSize, constraints, icon),
          contentBuilder: (sc) => buildSlidedBody(context, cartViewSize, sliderSize, constraints, sc),
          panelSize: sliderSize.width,
          contentSize: cartViewSize.width,
          departCurve: Curves.easeOutQuart,
          returnCurve: Curves.bounceOut,
          departDuration: const Duration(milliseconds: 900),
          gestureDetectOnlyPanel: true,
        );
      },
    );
  }

  Widget buildCartSliderButton(Size sliderSize, BoxConstraints constraints, SvgPicture icon) {
    return Positioned(
      right: 0,
      top: constraints.maxHeight * widget.heightOffsetFactor - sliderSize.height,
      child: SideTab(sliderSize: sliderSize, icon: icon),
    );
  }

  Widget buildSlidedBody(BuildContext context, Size cartSize, Size sliderSize, BoxConstraints constraints, ScrollController? sc) {
    if (_cachedBody == null || _cachedCartView == null) {
      _cachedBody ??= Positioned(
        right: 0,
        top: constraints.maxHeight * widget.heightOffsetFactor - sliderSize.height / 2 - cartSize.height / 2,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: cartSize.width,
            minWidth: cartSize.width,
            maxHeight: cartSize.height,
            minHeight: cartSize.height,
          ),
          child: CartView(scrollController: sc),
        ),
      );
    }

    return _cachedBody!;
  }
}
