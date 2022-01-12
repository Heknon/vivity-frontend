import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vivity/widgets/cart/shopping_cart.dart';
import 'package:vivity/widgets/map/map_widget.dart';
import 'package:vivity/widgets/map/widgeted_map.dart';
import 'package:latlong2/latlong.dart';

class Explore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => Stack(
        children: [
          WidgetedMap()
            ..addWidgetsToMap([
              MapWidget(
                location: LatLng(32.2276, 34.9996),
                size: const Size(50, 25),
                child: Material(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                  elevation: 7,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        "₪200",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            ]),
          Positioned(
            child: ConstrainedBox(child: ShoppingCart(), constraints: constraints,),
          ),
        ],
      ),
    );
  }
}
