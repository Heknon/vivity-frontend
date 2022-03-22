import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import '../explore/bloc/explore_bloc.dart';
import '../user/bloc/user_bloc.dart';
import 'bloc/map_bloc.dart' as map_bloc;
import 'location_service.dart';
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

  final Completer<LatLng> positionFutureImpl = Completer();
  late Completer<MapControllerImpl> controllerFutureImpl = Completer();
  bool initializedLocation = false;

  late MapGuiController _mapGuiController;
  late String token;

  @override
  void initState() {
    super.initState();
    fallbackLocation = LatLng(32.0668, 34.7649);
    token = (context.read<UserBloc>().state as UserLoggedInState).token;
    LocationService().getPosition(getCountryIfFail: true).then((loc) {
      if (initializedLocation) return;

      positionFutureImpl.complete(loc);

      controllerFutureImpl.future.then((controller) {
        controller.mapEventStream.listen((event) {
          if (event is! MapEventWithMove) return;

          registerMovementWithExploreBloc(controller.center, controller.bounds!);
        });
        if (loc != fallbackLocation) controller.move(loc, 13);
      });

      initializedLocation = true;
    });

    _mapGuiController = widget.controller ?? MapGuiController();
    _mapGuiController.addListener(() {
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return buildMapContents();
  }

  Widget buildMapContents() {
    print("Building : ${_mapGuiController.mapWidgets}");
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
          markers: _mapGuiController.mapWidgets.map((e) {
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

  void registerMovementWithExploreBloc(LatLng center, LatLngBounds bounds) {
    context.read<ExploreBloc>().add(ExploreMapMovementEvent(center, bounds, token));
  }
}

class MapGuiController extends ChangeNotifier {
  late Set<MapWidget> _mapWidgets;
  Iterable<MapWidget> get mapWidgets => _mapWidgets;

  MapGuiController({Set<MapWidget>? mapWidgets}) {
    _mapWidgets = mapWidgets ?? {};
  }

  void addWidgetToMap(MapWidget mapWidget) {
    _mapWidgets.add(mapWidget);
    notifyListeners();
  }

  void addWidgetsToMap(Iterable<MapWidget> mapWidgets) {
    _mapWidgets.addAll(mapWidgets);
    notifyListeners();
  }

  void removeWidgetFromMap(LatLng position) {
    _mapWidgets.removeWhere((e) => position == e.location);
    notifyListeners();
  }

  void removeWidgetsFromMap(Set<LatLng> positions) {
    _mapWidgets.removeWhere((e) => positions.contains(e.location));
    notifyListeners();
  }
}
