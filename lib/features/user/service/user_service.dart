import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/models/authentication_result.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/user/models/business_user.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/models/user_options.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/services/service_provider.dart';

import '../../item/models/item_model.dart';

class UserService extends ServiceProvider {
  static final UserService _userService = UserService._();

  static const String profilePictureRoute = '/profile_picture';
  static const String favoriteItemRoute = '/favorite';
  static const String exploreRoute = '/explore'; // TODO: Explore repo and search service
  static const String cartRoute = '/cart'; // TODO: Cart repo and service
  static const String addressRoute = '/address';
  static const String feedRoute = '/feed'; // TODO: Feed repo and search service
  static const String paymentRoute = '/payment';
  static const String resetPasswordRoute = '/password/forgot';
  static const String resetPasswordEmailSendRoute = '/forgot';
  static const String changePasswordRoute = '/password';

  final AuthenticationRepository _authRepository = AuthenticationRepository();

  UserService._() : super(baseRoute: userRoute);

  factory UserService() {
    return _userService;
  }

  Future<AsyncSnapshot<User>> getUser({
    bool includeCartItemModels = true,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await get(token: accessToken, queryParameters: {
        "include_cart_item_models": includeCartItemModels,
      });

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      Map<String, dynamic> userMap = response.data!;

      return AsyncSnapshot.withData(
        ConnectionState.done,
        _userFromMap(userMap),
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<User>> updateUser({
    String? email,
    String? phone,
    Unit? unit,
    String? currencyType,
    bool includeCartItemModels = true,
    bool includeBusiness = true,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await patch(token: accessToken, data: {
        "unit": unit?.index,
        "currency_type": currencyType,
        "email": email,
        "phone": phone,
      }, queryParameters: {
        "include_cart_item_models": includeCartItemModels,
        'include_business': includeBusiness,
      });

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      Map<String, dynamic> userMap = response.data!;

      return AsyncSnapshot.withData(
        ConnectionState.done,
        _userFromMap(userMap),
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<Uint8List>> updateProfilePicture({required File? file}) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await postUpload(subRoute: profilePictureRoute, token: accessToken, file: file);

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      return AsyncSnapshot.withData(
        ConnectionState.done,
        base64Decode(response.data['image']),
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<Uint8List>> getProfilePicture() async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await get(subRoute: profilePictureRoute, token: accessToken);

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      return AsyncSnapshot.withData(
        ConnectionState.done,
        response.data,
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<List<ItemModel>>> favoriteItem({
    required String id,
    required bool getItemModels,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await post(
        subRoute: favoriteItemRoute,
        token: accessToken,
        queryParameters: {
          'item_id': id,
          'get_item_models': getItemModels,
        },
      );

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      return AsyncSnapshot.withData(
        ConnectionState.done,
        (response.data as List<dynamic>).map((e) => ItemModel.fromMap(e)).toList(),
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<List<ItemModel>>> unfavoriteItem({
    required String id,
    required bool getItemModels,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await delete(
        subRoute: favoriteItemRoute,
        token: accessToken,
        queryParameters: {
          'item_id': id,
          'get_item_models': getItemModels,
        },
      );

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      return AsyncSnapshot.withData(
        ConnectionState.done,
        (response.data as List<dynamic>).map((e) => ItemModel.fromMap(e)).toList(),
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<String>> changePassword({
    required String password,
    required String newPassword,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await post(
        subRoute: changePasswordRoute,
        token: accessToken,
        data: {
          'password': password,
          'new_password': newPassword,
        },
      );

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      return AsyncSnapshot.withData(
        ConnectionState.done,
        response.data['access_token'],
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<bool>> sendForgotPasswordEmail({
    required String email,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await post(
        subRoute: resetPasswordEmailSendRoute,
        token: accessToken,
        data: {
          'email': email,
        },
      );

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      return AsyncSnapshot.withData(
        ConnectionState.done,
        response.data['success'],
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<bool>> resetPassword({
    required String temporary_auth,
    required String password,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await post(
        subRoute: resetPasswordRoute,
        token: accessToken,
        data: {
          'temporary_auth': temporary_auth,
          'password': password,
        },
      );

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      return AsyncSnapshot.withData(
        ConnectionState.done,
        response.data['success'],
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<bool>> payment({
    required String email,
  }) async {
    try {
      // TODO: PAYMENT SERVICE FOR ORDER FULFILMENT
      String accessToken = await _authRepository.getAccessToken();
      return AsyncSnapshot.nothing();
      AsyncSnapshot<Response> snapshot = await post(
        subRoute: paymentRoute,
        token: accessToken,
        data: {},
      );

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      if (response.statusCode! > 300) {
        return AsyncSnapshot.withError(ConnectionState.done, response);
      }

      return AsyncSnapshot.withData(
        ConnectionState.done,
        response.data['success'],
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  User _userFromMap(Map<String, dynamic> map) {
    Map<String, ItemModel>? cartIdItemModelMap;
    if (map.containsKey('cart_item_models')) {
      cartIdItemModelMap = {};
      List<ItemModel> cartItemModels = (map['cart_item_models'] as List<dynamic>).map((e) => ItemModel.fromMap(e)).toList();
      for (ItemModel cartItemModel in cartItemModels) {
        cartIdItemModelMap[cartItemModel.id.hexString] = cartItemModel;
      }
    }

    return map.containsKey('business_id') ? BusinessUser.fromMap(map, cartIdItemModelMap) : User.fromMap(map, cartIdItemModelMap);
  }
}
