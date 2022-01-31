import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/location_service.dart';

import 'map_widget.dart';

class MapGui extends StatefulWidget {
  final bool useMapBox;
  final BoxConstraints? constraints;
  final String mapBoxToken;
  final int flags;
  final MapGuiController? controller;

  MapGui({
    Key? key,
    this.useMapBox = true,
    this.constraints,
    required this.mapBoxToken,
    this.flags =
        InteractiveFlag.doubleTapZoom | InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove | InteractiveFlag.flingAnimation,
    this.controller,
  }) : super(key: key);



  @override
  _MapGuiState createState() => _MapGuiState();
}

class _MapGuiState extends State<MapGui> with AutomaticKeepAliveClientMixin {
  late LatLng fallbackLocation;

  final Set<MapWidget> _mapWidgets = {};

  final Completer<LatLng> positionFutureImpl = Completer();
  late Completer<MapControllerImpl> controllerFutureImpl = Completer();
  bool initializedLocation = false;

  late MapGuiController _mapGuiController;

  @override
  void initState() {
    super.initState();
    fallbackLocation = LatLng(32.0668, 34.7649);
    LocationService().getPosition(getCountryIfFail: true).then((loc) {
      // move to BLOC initialized when program starts.

      if (initializedLocation) return;

      positionFutureImpl.complete(loc);

      controllerFutureImpl.future.then((controller) {
        if (loc != fallbackLocation) controller.move(loc, 13);
      });

      initializedLocation = true;
    });

    _mapGuiController = widget.controller ?? MapGuiController();
    _mapGuiController._setState(this);
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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        _mapWidgets.add(mapWidget);
      });
    });
  }

  void addWidgetsToMap(Iterable<MapWidget> mapWidgets) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        _mapWidgets.addAll(mapWidgets);
      });
    });
  }

  void removeWidgetFromMap(LatLng position) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        _mapWidgets.remove(position);
      });
    });
  }

  void removeWidgetsFromMap(Iterable<LatLng> positions) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        _mapWidgets.removeAll(positions);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);

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
        interactiveFlags: widget.flags,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}',
          additionalOptions: {'accessToken': widget.mapBoxToken},
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

class MapGuiController {
  late _MapGuiState _state;

  void _setState(_MapGuiState state) {
    _state = state;
  }

  void addWidgetToMap(MapWidget mapWidget) {
    _state.addWidgetToMap(mapWidget);
  }

  void addWidgetsToMap(Iterable<MapWidget> mapWidgets) {
    _state.addWidgetsToMap(mapWidgets);
  }

  void removeWidgetFromMap(LatLng position) {
    _state.removeWidgetFromMap(position);
  }

  void removeWidgetsFromMap(Iterable<LatLng> positions) {
    _state.removeWidgetsFromMap(positions);
  }
}