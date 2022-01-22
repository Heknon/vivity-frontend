import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:map/map_widget.dart';
import 'package:map/widgeted_map.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:vivity/features/search_filter/filter_bar.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';
import 'package:vivity/widgets/cart/shopping_cart.dart';
import 'slideable_item_tab.dart';

  final controller = WidgetSwapperController();
class Explore extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => Stack(
        children: [
          WidgetedMap(
            mapBoxToken: mapBoxToken,
          )..addWidgetsToMap([
              MapWidget(
                location: LatLng(32.2276, 34.9996),
                size: const Size(50, 25),
                child: Material(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                  elevation: 7,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: InkWell(
                        onTap: () => controller.toggle(),
                        child: const Text(
                          "₪200",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]),
          Positioned(
            child: ConstrainedBox(
              child: ShoppingCart(),
              constraints: constraints,
            ),
          ),
          Positioned(
            child: ConstrainedBox(
              child: const SlideableItemTab(),
              constraints: constraints,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 50,
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: 50,
                maxHeight: 120
              ),
              child: WidgetSwapper(
                filterViewController: controller,
                bar: FilterBar(controller: controller,),
                sideBar: FilterSideBar(controller: controller,),
              ),
            ),
          )
        ],
      ),
    );
  }
}
