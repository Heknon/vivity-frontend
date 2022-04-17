import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/home/explore/bloc/explore_bloc.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlng/latlng.dart' as latlng;
import 'location_service.dart';
import 'map_widget.dart';

final ValueKey<int> mapKey =  ValueKey(432543);

class MapGui extends StatefulWidget {
  final bool useMapBox;
  final BoxConstraints? constraints;
  final String mapBoxToken;
  final int flags;
  final MapControllerImpl? controller;
  final MapWidget? Function(dynamic data)? transformDataToWidget;

  MapGui({
    Key? key,
    this.useMapBox = true,
    this.constraints,
    required this.mapBoxToken,
    this.flags =
        InteractiveFlag.doubleTapZoom | InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove | InteractiveFlag.flingAnimation,
    this.controller,
    this.transformDataToWidget,
  }) : super(key: key);

  @override
  _MapGuiState createState() => _MapGuiState();
}

class _MapGuiState extends State<MapGui> with AutomaticKeepAliveClientMixin {
  bool createdMap = false;

  latlng.LatLng fallbackLocation = latlng.LatLng(32.0668, 34.7649);
  late MapControllerImpl _mapController;
  late final ExploreBloc _exploreBloc;

  late String token;

  @override
  void initState() {
    super.initState();

    _mapController = widget.controller ?? MapControllerImpl();

    LocationService _locationService = LocationService();

    _locationService.getLocationUpdateStream(defaultLocation: fallbackLocation).then((stream) {
      stream.listen((loc) {
        if (!createdMap) return;
        _mapController.move(LatLng(loc.latitude, loc.longitude), _mapController.zoom);
      });
    }).catchError((err) {
      if (err is LatLng) {
        _mapController.move(LatLng(err.latitude, err.longitude), _mapController.zoom);
      } else {
        if (!createdMap) return;
        _mapController.move(LatLng(fallbackLocation.latitude, fallbackLocation.longitude), _mapController.zoom);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _exploreBloc = context.read<ExploreBloc>();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  void onMapCreate(MapControllerImpl controllerImpl) {
    createdMap = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildMapContents();
  }

  Widget buildMapContents() {
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        List<MapWidget> widgets = List.empty(growable: true);
        if (state is ExploreSearched && widget.transformDataToWidget != null) {
          for (ItemModel item in state.itemsFound) {
            MapWidget? result = widget.transformDataToWidget!(item);
            if (result != null) widgets.add(result);
          }

          for (Business business in state.businessesFound) {
            MapWidget? result = widget.transformDataToWidget!(business);
            if (result != null) widgets.add(result);
          }
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: isMapWasInitialized ? _mapController.center : LatLng(fallbackLocation.latitude, fallbackLocation.longitude),
            zoom: isMapWasInitialized ? _mapController.zoom : 13,
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
              markers: widgets
                  .map(
                    (e) => Marker(
                      width: e.size.width,
                      height: e.size.height,
                      point: e.location,
                      builder: (ctx) => e.child,
                    ),
                  )
                  .toList(),
            )
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  bool get isMapWasInitialized {
    try {
      _mapController.center;
      return true;
    } catch (e) {
      return false;
    }
  }
}

// class MapGuiController extends ChangeNotifier {
//   late Set<MapWidget> _mapWidgets;
//
//   Iterable<MapWidget> get mapWidgets => _mapWidgets;
//
//   MapGuiController({Set<MapWidget>? mapWidgets}) {
//     _mapWidgets = mapWidgets ?? {};
//   }
//
//   void addWidgetToMap(MapWidget mapWidget) {
//     _mapWidgets.add(mapWidget);
//     notifyListeners();
//   }
//
//   void addWidgetsToMap(Iterable<MapWidget> mapWidgets) {
//     _mapWidgets.addAll(mapWidgets);
//     notifyListeners();
//   }
//
//   void removeWidgetFromMap(LatLng position) {
//     _mapWidgets.removeWhere((e) => position == e.location);
//     notifyListeners();
//   }
//
//   void removeWidgetsFromMap(Set<LatLng> positions) {
//     _mapWidgets.removeWhere((e) => positions.contains(e.location));
//     notifyListeners();
//   }
//
//   void clearWidgets() {
//     _mapWidgets.clear();
//     notifyListeners();
//   }
// }
