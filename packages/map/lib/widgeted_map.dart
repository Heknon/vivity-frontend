import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'map_gui.dart';
import 'map_widget.dart';

class WidgetedMap extends StatelessWidget {
  WidgetedMap({Key? key, useMapBox = true, this.constraints, required String mapBoxToken}) : super(key: key) {
    _mapKey = GlobalKey<MapGuiState>(debugLabel: "Map GUI | Explore");
    _mapGui = MapGui(
      useMapBox: useMapBox,
      constraints: constraints,
      key: _mapKey, mapBoxToken: mapBoxToken,
    );
  }

  late MapGui _mapGui;
  late GlobalKey<MapGuiState> _mapKey;
  final BoxConstraints? constraints;

  void addWidgetToMap(MapWidget mapWidget) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _mapKey.currentState?.addWidgetToMap(mapWidget);
    });
  }

  void removeWidgetFromMap(LatLng position) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _mapKey.currentState?.removeWidgetFromMap(position);
    });
  }

  void addWidgetsToMap(Iterable<MapWidget> mapWidgets) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _mapKey.currentState?.addWidgetsToMap(mapWidgets);
    });
  }

  void removeWidgetsFromMap(Iterable<LatLng> positions) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _mapKey.currentState?.removeWidgetsFromMap(positions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _mapGui, constraints: constraints,);
  }
}
