import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/user/errors/user_error.dart';
import 'package:vivity/features/user/models/business_user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/services/service_provider.dart';

import '../../user/models/user.dart';

class BusinessService extends ServiceProvider {
  static final BusinessService _businessService = BusinessService._();

  final UserRepository _userRepository = UserRepository();
  final AuthenticationRepository _authRepository = AuthenticationRepository();

  static const specificBusinessRoute = '/{business_id}';
  static const businessOrdersRoute = '/orders';
  static const businessDeleteRoute = '/delete'; // TODO: Implement backend

  BusinessService._() : super(baseRoute: businessRoute);

  factory BusinessService() {
    return _businessService;
  }

  Future<AsyncSnapshot<Business>> getUserBusiness() async {
    User user = await _userRepository.getUser();
    if (user is! BusinessUser) throw UserNoAccessException();

    AsyncSnapshot<Response> snapshot = await get();

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
      Business.fromMap(response.data!),
    );
  }

  Future<AsyncSnapshot<Business>> createBusiness({
    required String name,
    required String email,
    required String phone,
    required double latitude,
    required double longitude,
    required String nationalBusinessId,
    required File ownerId,
  }) async {
    User user = await _userRepository.getUser();
    if (user is! BusinessUser) throw UserNoAccessException();

    AsyncSnapshot<Response> snapshot = await post(token: await _authRepository.getAccessToken(), data: {
      "name": name,
      "email": email,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
      "business_national_number": nationalBusinessId,
      "business_owner_id": base64Encode(await ownerId.readAsBytes()),
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

    _authRepository.login(accessToken: response.data['token'], refreshToken: await _authRepository.getRefreshToken());
    return AsyncSnapshot.withData(
      ConnectionState.done,
      Business.fromMap(response.data['business']!),
    );
  }

  Future<AsyncSnapshot<Business>> updateUserBusiness({
    required String name,
    required String email,
    required String phone,
    required double latitude,
    required double longitude,
    required String nationalBusinessId,
    required File ownerId,
  }) async {
    User user = await _userRepository.getUser();
    if (user is! BusinessUser) throw UserNoAccessException();

    AsyncSnapshot<Response> snapshot = await patch(data: {
      "name": name,
      "email": email,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
      "business_national_number": nationalBusinessId,
      "owner_id": base64Encode(await ownerId.readAsBytes()),
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

    return AsyncSnapshot.withData(
      ConnectionState.done,
      Business.fromMap(response.data!),
    );
  }


}
