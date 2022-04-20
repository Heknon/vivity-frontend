import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';

part 'liked_event.dart';

part 'liked_state.dart';

class LikedBloc extends Bloc<LikedEvent, LikedState> {
  UserRepository _userRepository = UserRepository();

  LikedBloc() : super(LikedUnloaded()) {
    on<LikedLoadEvent>((event, emit) async {
      User user = await _userRepository.getUser();
      emit(LikedLoaded(user.likedItems.map((e) => e.id.hexString).toSet()));
    });

    on<LikedAddItemEvent>((event, emit) async {
      if (state is! LikedLoaded) return;

      _userRepository.addLikedItem(likedItemId: event.itemId).then((value) => LikedLoaded(value.likedItems.map((e) => e.id.hexString).toSet()));
      emit(LikedLoaded((state as LikedLoaded).likedItems.map((e) => e).toSet()..add(event.itemId)));
    });

    on<LikedRemoveItemEvent>((event, emit) async {
      if (state is! LikedLoaded) return;

      _userRepository.removeLikedItem(likedItemId: event.itemId).then((value) => LikedLoaded(value.likedItems.map((e) => e.id.hexString).toSet()));
      emit(LikedLoaded((state as LikedLoaded).likedItems.map((e) => e).toSet()..remove(event.itemId)));
    });
  }
}
