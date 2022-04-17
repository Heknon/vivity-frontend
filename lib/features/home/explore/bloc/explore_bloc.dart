import 'dart:async';
import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlng/latlng.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/search/errors/search_execption.dart';
import 'package:vivity/features/search/service/search_service.dart';
import 'package:vivity/helpers/map_helper.dart';

part 'explore_event.dart';

part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final SearchService _searchService = SearchService();

  final MapControllerImpl mapController = MapControllerImpl();
  LatLng? lastUpdateLocation;
  late final RestartableTimer _timer;

  ExploreBloc() : super(ExploreBlocked()) {
    _timer = RestartableTimer(const Duration(milliseconds: 3000), shouldDoSearchRoutine);

    on<ExploreSearchEvent>((event, emit) async {
      if (state is! ExploreSearchable) return;

      List<ItemModel> items = await getItemsNearLocation(location: event.location, radius: event.radius);
      List<Business> businesses = await getBusinessesNearLocation(location: event.location, radius: event.radius);

      lastUpdateLocation = event.location;
      emit(ExploreSearched(itemsFound: items, businessesFound: businesses));
    });

    on<ExploreLoad>((event, emit) {
      if (state is ExploreSearchable) return;

      _timer.reset();
      emit(ExploreSearchable());
    });

    on<ExploreUnload>((event, emit) {
      if (state is! ExploreSearchable) return;

      _timer.cancel();
      emit(ExploreBlocked());
    });
  }

  Future<List<ItemModel>> getItemsNearLocation({
    required LatLng location,
    required double radius,
  }) async {
    AsyncSnapshot<List<ItemModel>> snapshot = await _searchService.exploreItems(position: location, radius: radius);
    if (snapshot.hasError || !snapshot.hasData) {
      throw SearchException(message: 'Failed to find items in vicinity');
    }

    List<ItemModel> items = snapshot.data!;
    return items;
  }

  Future<List<Business>> getBusinessesNearLocation({
    required LatLng location,
    required double radius,
  }) async {
    AsyncSnapshot<List<Business>> snapshot = await _searchService.exploreBusinesses(position: location, radius: radius);
    if (snapshot.hasError || !snapshot.hasData) {
      throw SearchException(message: 'Failed to find businesses in vicinity');
    }

    return snapshot.data!;
  }

  void shouldDoSearchRoutine() {
    ExploreState state = this.state;
    if (state is! ExploreSearchable) {
      if (_timer.isActive) _timer.cancel();
      return;
    }
    const int blockSearchBelowDistance = 60;
    if (mapController.ifInitialized() == null) {
      _timer.reset();
      return;
    }

    double distanceFromLastFetch = lastUpdateLocation != null
        ? Geolocator.distanceBetween(
            mapController.center.latitude,
            mapController.center.longitude,
            lastUpdateLocation!.latitude,
            lastUpdateLocation!.longitude,
          )
        : blockSearchBelowDistance + 1;

    if (distanceFromLastFetch < blockSearchBelowDistance) {
      _timer.reset();
      return;
    }

    add(ExploreSearchEvent(
      radius: Geolocator.distanceBetween(
        mapController.center.latitude,
        mapController.center.longitude,
        mapController.bounds!.southEast.latitude,
        mapController.bounds!.southEast.longitude,
      ),
      location: LatLng(mapController.center.latitude, mapController.center.longitude),
    ));
    _timer.reset();
  }
}
