import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:vivity/services/network_exception.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository _userRepository = UserRepository();

  HomeBloc() : super(HomeBlocked()) {
    on<HomeLoadEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        User user = await _userRepository.getUser();
        emit(HomeLoaded(user: user));
      } on NetworkException catch (e) {
        emit(HomeLoadFailed(
          message:
              e.response?.data['error'] ?? e.message ?? 'Authentication failed',
        ));
      }
    });

    on<HomeUnloadEvent>((event, emit) async {
      emit(HomeBlocked());
    });
  }
}
