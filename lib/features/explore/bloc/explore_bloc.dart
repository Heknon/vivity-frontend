import 'dart:async';
import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vivity/features/map/map_gui.dart';
import 'package:vivity/features/map/map_widget.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/services/item_service.dart';

import '../../item/models/item_model.dart';

part 'explore_event.dart';

part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  late RestartableTimer _timer;
  late bool registeredUserBlocListener = false;

  ExploreBloc() : super(ExploreUnloaded()) {
    _timer = RestartableTimer(const Duration(milliseconds: 3000), timerDone);

    on<ExploreControllerUpdateEvent>((event, emit) async {
      ExploreState initialState = state;

      ExploreLoaded resState = initialState is ExploreLoaded
          ? initialState.copyWith(controller: event.controller, token: event.token)
          : ExploreLoaded(
              token: event.token,
              controller: event.controller,
              itemModels: [],
              lastUpdateLocation: event.controller.center,
              mapGuiController: MapGuiController(),
            );

      _timer.reset();
      emit(resState);
    });

    on<ExploreRegisterUserBlocListener>((event, emit) {
      if (registeredUserBlocListener) return;

      event.userBloc.stream.listen((userState) {
        if (userState is! UserLoggedInState || state is! ExploreLoaded) return;
        if ((state as ExploreLoaded).token == userState.accessToken) return;

        add(ExploreUpdateAccessTokenEvent(userState.accessToken));
      });

      registeredUserBlocListener = true;
    });

    on<ExploreUpdateAccessTokenEvent>((event, emit) {
      if (state is! ExploreLoaded) return;
      if ((state as ExploreLoaded).token == event.token) return;

      ExploreLoaded newState = (state as ExploreLoaded).copyWith(token: event.token);
      emit(newState);
    });

    on<ExploreUpdateEvent>((event, emit) async {
      ExploreState state = this.state;
      if (state is ExploreLoaded) {
        ExploreState result = await state.fetchItemModels();
        emit(result);
        _timer.reset();
        return;
      }

      emit(state);
      _timer.reset();
    });

    on<ExploreUnload>((event, emit) {
      _timer.cancel();
      emit(ExploreUnloaded());
    });
  }

  void timerDone() {
    ExploreState state = this.state;
    if (state is! ExploreLoaded) return;

    double distanceFromLastFetch = Geolocator.distanceBetween(
        state.controller.center.latitude, state.controller.center.longitude, state.lastUpdateLocation.latitude, state.lastUpdateLocation.longitude);
    if (distanceFromLastFetch < 10) {
      _timer.reset();
      return;
    }

    add(ExploreUpdateEvent());
    _timer.reset();
  }
}
