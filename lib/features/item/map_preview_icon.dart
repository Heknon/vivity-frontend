import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';

import '../map/map_widget.dart';
import 'package:latlong2/latlong.dart';

class MapPreviewIcon extends StatelessWidget {
  final ItemModel item;

  const MapPreviewIcon({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      elevation: 7,
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.white,
        child: Center(
          child: InkWell(
            onTap: () {

            },
            child: Text(
              "₪${item.price.toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
