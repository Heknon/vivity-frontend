import 'dart:async';
import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vivity/features/map/map_widget.dart';
import 'package:vivity/services/item_service.dart';

import '../../item/models/item_model.dart';

part 'explore_event.dart';

part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  late RestartableTimer _timer;

  ExploreBloc() : super(ExploreUnloaded()) {
    _timer = RestartableTimer(const Duration(seconds: 5), timerDone);

    on<ExploreMapMovementEvent>((event, emit) async {
      ExploreState state = this.state;
      ExploreLoaded? resState;

      if (state is ExploreUnloaded) {
        if (event.token == null) throw Exception('Missing token!');
        resState = ExploreLoaded(
          position: event.center,
          registeredPosition: event.center,
          bounds: event.bounds,
          registeredBounds: event.bounds,
          itemModels: List.empty(growable: true),
          token: event.token!,
        );

        await resState.fetchItemModels();
      } else if (state is ExploreLoaded) {
        double distanceBetweenRegisteredLocation = Geolocator.distanceBetween(
            state.registeredPosition.latitude, state.registeredPosition.longitude, event.center.latitude, event.center.longitude);
        if (distanceBetweenRegisteredLocation < 50) {
          _timer.reset();
        }

        resState = state.copyWith(
          position: event.center,
          bounds: event.bounds,
        );
      }

      emit(resState ?? ExploreUnloaded());
    });

    on<ExploreMapRegisteredMovementEvent>((event, emit) async {
      ExploreState state = this.state;
      if (state is ExploreLoaded) {
        ExploreLoaded resultState = state.copyWith(
          registeredPosition: event.center ?? state.position,
          registeredBounds: event.bounds ?? state.bounds,
        );

        await resultState.fetchItemModels();
        emit(resultState);
        return;
      }

      emit(state);
    });
  }

  void timerDone() {
    ExploreState state = this.state;
    if (state is! ExploreLoaded) return;

    double distanceBetweenRegisteredLocation = Geolocator.distanceBetween(
        state.registeredPosition.latitude, state.registeredPosition.longitude, state.position.latitude, state.position.longitude);
    if (distanceBetweenRegisteredLocation < 20) {
      _timer.reset();
      return;
    }

    print("interesting");
    add(ExploreMapRegisteredMovementEvent());
    _timer.reset();
  }
}
