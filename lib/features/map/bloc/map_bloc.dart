import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/map/location_service.dart';

import '../map_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationService _locationService = LocationService();

  MapBloc() : super(MapInitial()) {
    on<MapLocationModifiedEvent>((event, emit) {
      if (this.state is! MapLoadedState) return;

      MapLoadedState state = this.state as MapLoadedState;
      emit(state.copyWith(location: event.location));
    });

    on<MapBoundsModifiedEvent>((event, emit) {
      if (this.state is! MapLoadedState) return;

      MapLoadedState state = this.state as MapLoadedState;
      emit(state.copyWith(bounds: event.bounds));
    });

    on<MapRefreshLocationEvent>((event, emit) async {
      if (event.disturbed) {
        emit(MapDisturbedLoadingState());
      } else {
        emit(MapLoadingState.fromLoaded(state as MapLoadedState));
      }

      LatLng resultLocation = await _locationService.getPosition(defaultLocation: event.defaultLocation);

      emit(MapLoadedState(resultLocation, null, state is MapWidgetedState ? (state as MapWidgetedState).widgets : List.empty(growable: true)));
    });

    on<MapWidgetAddEvent>((event, emit) {
      if (this.state is! MapWidgetedState) return;
      MapWidgetedState state = this.state as MapWidgetedState;

      Set<MapWidget> widgets = Set.of(state.widgets);
      widgets.addAll(event.widgets);
      emit(state.copyWith(widgets: widgets));
    });

    on<MapWidgetRemoveEvent>((event, emit) {
      if (this.state is! MapWidgetedState) return;
      MapWidgetedState state = this.state as MapWidgetedState;

      Set<MapWidget> widgets = Set.of(state.widgets);
      widgets.removeAll(event.positions);
      emit(state.copyWith(widgets: widgets));
    });
  }

}
