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

  MapGui({
    Key? key,
    this.useMapBox = true,
    this.constraints,
    required this.mapBoxToken,
    this.flags =
        InteractiveFlag.doubleTapZoom | InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove | InteractiveFlag.flingAnimation,
  }) : super(key: key);

  @override
  _MapGuiState createState() => _MapGuiState();
}

int initNum = 0;

class _MapGuiState extends State<MapGui> with AutomaticKeepAliveClientMixin {
  bool registeredLocation = false;
  LatLng fallbackLocation = LatLng(32.0668, 34.7649);
  late MapControllerImpl _mapController;

  late String token;

  @override
  void initState() {
    super.initState();
    ExploreBloc exploreBloc = context.read<ExploreBloc>();
    ExploreState state = exploreBloc.state;
    if (state is ExploreLoaded) {
      _mapController = state.controller;
      exploreBloc.add(ExploreUpdateEvent());
      return;
    }

    _mapController = MapControllerImpl();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  void _onMapCreated(MapController _controller) async {
    MapControllerImpl controller = _controller as MapControllerImpl;
    if (mounted && initNum.isOdd) {
      context.read<ExploreBloc>().add(ExploreControllerUpdateEvent(controller, (context.read<UserBloc>().state as UserLoggedInState).token));
      _mapController = _controller;
    }
    initNum++;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildMapContents();
  }

  Widget buildMapContents() {
    return BlocConsumer<ExploreBloc, ExploreState>(
      listenWhen: (prev, curr) => prev is ExploreUnloaded && curr is ExploreLoaded,
      listener: (ctx, state) {
        if (state is! ExploreLoaded) return;
        LocationService().getPosition(getCountryIfFail: true, defaultLocation: fallbackLocation).then((loc) async {
          if (!mounted) return;

          state.controller.move(loc, state.controller.zoom);
          context.read<ExploreBloc>().add(ExploreUpdateEvent());
        }).catchError((err) async {
          if (!mounted) return;

          state.controller.move(state.controller.center, state.controller.zoom);
          context.read<ExploreBloc>().add(ExploreUpdateEvent());
        });
      },
      builder: (context, state) {
        MapOptions mapOptions = MapOptions(
          center: fallbackLocation,
          zoom: 13,
          onMapCreated: _onMapCreated,
          controller: _mapController,
          maxZoom: 20,
          minZoom: 4,
          rotationThreshold: 0,
          interactiveFlags: widget.flags,
        );

        if (state is ExploreLoaded) {
          mapOptions = MapOptions(
            center: state.controller.center,
            zoom: state.controller.zoom,
            onMapCreated: _onMapCreated,
            controller: state.controller,
            maxZoom: 20,
            minZoom: 4,
            rotationThreshold: 0,
            interactiveFlags: widget.flags,
          );
        }
        return FlutterMap(
          options: mapOptions,
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
              markers: state is ExploreLoaded
                  ? state.mapGuiController.mapWidgets.map((e) {
                      return Marker(
                        width: e.size.width,
                        height: e.size.height,
                        point: e.location,
                        builder: (ctx) => e.child,
                      );
                    }).toList()
                  : [],
            )
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
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

  void clearWidgets() {
    _mapWidgets.clear();
    notifyListeners();
  }
}
