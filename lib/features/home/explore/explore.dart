import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:map/map_gui.dart';
import 'package:map/map_widget.dart';
import '../../cart/shopping_cart.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:vivity/features/search_filter/filter_bar.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';
import 'slideable_item_tab.dart';

final mapGuiController = MapGuiController();

class Explore extends StatelessWidget {
  final _widgetSwapController = WidgetSwapperController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      mapGuiController.addWidgetsToMap([
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
                  onTap: () => _widgetSwapController.toggle(),
                  child: const Text(
                    "₪200",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        )
      ]);
    });

    return LayoutBuilder(
      builder: (ctx, constraints) => Stack(
        children: [
          MapGui(
            mapBoxToken: mapBoxToken,
            controller: mapGuiController,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 50,
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: 50,
                maxHeight: 120,
              ),
              child: WidgetSwapper(
                filterViewController: _widgetSwapController,
                bar: FilterBar(
                  controller: _widgetSwapController,
                ),
                sideBar: FilterSideBar(
                  controller: _widgetSwapController,
                ),
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}
