import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:vivity/utils/services/location_service.dart';
import 'package:vivity/widgets/map/map_widget.dart';

class MapGui extends StatefulWidget {
  MapGui({Key? key, this.useMapBox = true, this.constraints}) : super(key: key);

  final bool useMapBox;
  final BoxConstraints? constraints;

  @override
  MapGuiState createState() => MapGuiState();

  void test() {
    print(key);
  }
}

class MapGuiState extends State<MapGui> with AutomaticKeepAliveClientMixin {
  late LatLng fallbackLocation;

  final Set<MapWidget> _mapWidgets = {};

  final Completer<LatLng> positionFutureImpl = Completer();
  late Completer<MapControllerImpl> controllerFutureImpl = Completer();

  @override
  void initState() {
    super.initState();
    fallbackLocation = LatLng(32.0668, 34.7649);
    getPosition(getCountryIfFail: true).then((loc) {
      positionFutureImpl.complete(loc);

      controllerFutureImpl.future.then((controller) {
        if (loc != fallbackLocation) controller.move(loc, 13);
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();
  }

  void _onMapCreated(MapController _controller) async {
    MapControllerImpl controller = _controller as MapControllerImpl;
    controllerFutureImpl.complete(controller);
  }

  void addWidgetToMap(MapWidget mapWidget) {
    setState(() {
      _mapWidgets.add(mapWidget);
    });
  }

  void addWidgetsToMap(Iterable<MapWidget> mapWidgets) {
    setState(() {
      _mapWidgets.addAll(mapWidgets);
    });
  }

  void removeWidgetFromMap(LatLng position) {
    setState(() {
      _mapWidgets.remove(position);
    });
  }

  void removeWidgetsFromMap(Iterable<LatLng> positions) {
    setState(() {
      _mapWidgets.removeAll(positions);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildMapContents();
  }

  Widget buildMapContents() {
    return FlutterMap(
      options: MapOptions(
        center: fallbackLocation,
        zoom: 8,
        onMapCreated: _onMapCreated,
        controller: MapControllerImpl(),
        maxZoom: 20,
        minZoom: 4,
        rotationThreshold: 0,
        interactiveFlags: InteractiveFlag.doubleTapZoom | InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove | InteractiveFlag.flingAnimation,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}',
          additionalOptions: {'accessToken': mapBoxToken},
          maxNativeZoom: 18,
          maxZoom: 20,
          minZoom: 4,
          minNativeZoom: 4,
        ),
        MarkerLayerOptions(
          markers: _mapWidgets.map((e) {
            return Marker(
              width: e.size.width,
              height: e.size.height,
              point: e.location,
              builder: (ctx) => e.child,
            );
          }).toList(),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
