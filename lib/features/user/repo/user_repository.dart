import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/features/user/errors/user_error.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/models/user_options.dart';
import 'package:vivity/features/user/service/user_service.dart';

class UserRepository {
  final AuthenticationRepository _authRepository = AuthenticationRepository();
  final ItemRepository _itemRepository = ItemRepository();
  final UserService _userService = UserService();

  static final UserRepository _userRepository = UserRepository._();

  UserRepository._();

  factory UserRepository() {
    return _userRepository;
  }

  User? _user;

  Future<User> getUser({bool update = false}) async {
    if (_user != null && !update) return _user!;

    AsyncSnapshot<User> snapshot = await _userService.getUser();
    if (snapshot.hasError || !snapshot.hasData) {
      throw UserGetFailedException();
    }

    _user = snapshot.data!;
    return _user!;
  }

  Future<User> updateUser({
    String? email,
    String? phone,
    Unit? unit,
    String? currencyType,
    bool updateDatabase = true,
  }) async {
    if (updateDatabase) {
      AsyncSnapshot<User> snapshot = await _userService.updateUser(email: email, phone: phone, unit: unit, currencyType: currencyType);

      if (snapshot.hasError || !snapshot.hasData) {
        throw UserUpdateFailedException();
      }

      _user = snapshot.data!;
      return _user!;
    }

    User user = await getUser();
    _user = user.copyWith(
      email: email,
      phone: phone,
      userOptions: user.userOptions.copyWith(
        currencyType: currencyType,
        unit: unit,
      ),
    );

    return _user!;
  }

  Future<User> updateProfilePicture({
    required File? file,
    bool updateDatabase = true,
  }) async {
    if (updateDatabase) {
      AsyncSnapshot<Uint8List> snapshot = await _userService.updateProfilePicture(file: file);

      if (snapshot.hasError || !snapshot.hasData) {
        throw UserUpdateFailedException();
      }

      _user = await getUser();
      _user = _user?.copyWith(profilePicture: (snapshot.data?.length ?? 0) < 100 ? null : snapshot.data!);

      return _user!;
    }

    User user = await getUser();
    _user = user.copyWith(
      profilePicture: file?.readAsBytesSync(),
    );

    return _user!;
  }

  Future<Uint8List?> getProfilePicture({
    required File? file,
    bool update = true,
  }) async {
    if (update) {
      AsyncSnapshot<Uint8List> snapshot = await _userService.getProfilePicture();

      if (snapshot.hasError || !snapshot.hasData) {
        throw UserGetProfilePictureFailedException();
      }

      User user = await getUser();
      _user = user.copyWith(profilePicture: snapshot.data);

      return snapshot.data;
    }

    return _user?.profilePicture;
  }

  Future<User> addLikedItem({
    required String likedItemId,
  }) async {
    AsyncSnapshot<List<ItemModel>> snapshot = await _userService.favoriteItem(id: likedItemId, getItemModels: true);

    if (snapshot.hasError || !snapshot.hasData) {
      throw UserFavoriteFailedException();
    }

    List<ItemModel> itemModels = snapshot.data!;

    _itemRepository.gracefullyUpdateItems(snapshot.data!);
    _user = (await getUser()).copyWith(likedItems: itemModels);

    return _user!;
  }

  Future<User> removeLikedItem({
    required String likedItemId,
  }) async {
    AsyncSnapshot<List<ItemModel>> snapshot = await _userService.unfavoriteItem(id: likedItemId, getItemModels: true);

    if (snapshot.hasError || !snapshot.hasData) {
      throw UserRemoveFavoriteFailedException();
    }

    List<ItemModel> itemModels = snapshot.data!;

    _itemRepository.gracefullyUpdateItems(snapshot.data!);
    _user = (await getUser()).copyWith(likedItems: itemModels);

    return _user!;
  }
}
