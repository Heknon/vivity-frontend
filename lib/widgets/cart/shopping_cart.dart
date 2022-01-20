import 'package:advanced_panel/panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/item/cart_item/cart_item.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'cart_view.dart';
import 'side_tab.dart';

class ShoppingCart extends StatelessWidget {
  double heightOffsetFactor = 0.4;

  ShoppingCart({Key? key}) : super(key: key);

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
          contentBuilder: (sc) => buildSlidedBody(cartViewSize, sliderSize, constraints, sc),
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
      top: constraints.maxHeight * heightOffsetFactor - sliderSize.height,
      child: SideTab(sliderSize: sliderSize, icon: icon),
    );
  }

  List<CartItemModel> models = [cartItemModel, cartItemModel2];
  Widget buildSlidedBody(Size cartSize, Size sliderSize, BoxConstraints constraints, ScrollController? sc) {
    return Positioned(
      right: 0,
      top: constraints.maxHeight * heightOffsetFactor - sliderSize.height / 2 - cartSize.height / 2,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: cartSize.width,
          minWidth: cartSize.width,
          maxHeight: cartSize.height,
          minHeight: cartSize.height
        ),
        child: CartView(scrollController: sc, itemModels: List.generate(5, (index) => models[index % 2]),),
      ),
    );
  }
}
