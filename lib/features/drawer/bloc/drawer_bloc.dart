import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/user/models/business_user.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';

part 'drawer_event.dart';

part 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final UserRepository _userRepository = UserRepository();

  DrawerBloc() : super(DrawerUnloaded()) {
    on<DrawerLoadEvent>((event, emit) async {
      emit(DrawerLoading());

      User user = await _userRepository.getUser();
      emit(DrawerLoaded(
        ownsBusiness: user is BusinessUser,
        isAdmin: user.isAdmin,
        profilePicture: user.profilePicture,
        name: user.name,
      ));
    });

    on<DrawerUpdateProfilePictureEvent>((event, emit) async {
      if (state is! DrawerLoaded) return;

      emit((state as DrawerLoaded).copyWith(profilePicture: event.file.readAsBytesSync()));
      User user = await _userRepository.updateProfilePicture(file: event.file);
      emit((state as DrawerLoaded).copyWith(ownsBusiness: user is BusinessUser, isAdmin: user.isAdmin, profilePicture: user.profilePicture, name: user.name));
    });

    on<DrawerDeleteProfilePictureEvent>((event, emit) async {
      if (state is! DrawerLoaded) return;

      emit((state as DrawerLoaded).copyWith(profilePicture: null));
      User user = await _userRepository.updateProfilePicture(file: null);
      emit((state as DrawerLoaded).copyWith(ownsBusiness: user is BusinessUser, isAdmin: user.isAdmin, profilePicture: user.profilePicture, name: user.name));
    });
  }
}
