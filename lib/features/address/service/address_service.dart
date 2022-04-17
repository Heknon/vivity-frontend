import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/services/service_provider.dart';

class AddressService extends ServiceProvider {
  static final AddressService _addressService = AddressService._();

  final AuthenticationRepository _authRepository = AuthenticationRepository();

  AddressService._() : super(baseRoute: addressRoute);

  factory AddressService() => _addressService;

  Future<AsyncSnapshot<List<Address>>> getAddresses() async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await get(token: accessToken);
      snapshot = faultyResponseShouldReturn(snapshot);

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      return AsyncSnapshot.withData(
        ConnectionState.done,
        (response.data as List<dynamic>).map((e) => Address.fromMap(e)).toList(),
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<List<Address>>> addAddress({
    required Address address,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await post(token: accessToken, data: address.toMap());
      snapshot = faultyResponseShouldReturn(snapshot);

      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      return AsyncSnapshot.withData(
        ConnectionState.done,
        (response.data as List<dynamic>).map((e) => Address.fromMap(e)).toList(),
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  Future<AsyncSnapshot<List<Address>>> removeAddress({
    required int index,
  }) async {
    try {
      String accessToken = await _authRepository.getAccessToken();
      AsyncSnapshot<Response> snapshot = await delete(
        token: accessToken,
        queryParameters: {
          'index': index,
        },
      );

      snapshot = faultyResponseShouldReturn(snapshot);
      if (snapshot.hasError) {
        return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
      } else if (!snapshot.hasData) {
        return AsyncSnapshot.nothing();
      }

      Response response = snapshot.data!;
      return AsyncSnapshot.withData(
        ConnectionState.done,
        (response.data as List<dynamic>).map((e) => Address.fromMap(e)).toList(),
      );
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }
}
