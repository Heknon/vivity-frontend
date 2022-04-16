import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/services/service_provider.dart';

class AdminService extends ServiceProvider {
  static final AdminService _adminService = AdminService._();

  final AuthenticationRepository _authRepository = AuthenticationRepository();

  static const String unapprovedBusinessesRoute = '/business/unapproved';
  static const String approvedBusinessesRoute = '/business/approved';
  static const String approveBusinessesRoute = '/business/approve';

  AdminService._();

  factory AdminService() => _adminService;

  Future<AsyncSnapshot<List<Business>>> getUnapprovedBusinesses({
    required bool getImages,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await get(subRoute: unapprovedBusinessesRoute, token: accessToken, queryParameters: {
      "get_images": getImages,
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
      (snapshot.data! as List<dynamic>).map((e) => Business.fromMap(e)).toList(),
    );
  }

  Future<AsyncSnapshot<List<Business>>> getApprovedBusinesses({
    required bool getImages,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await get(subRoute: approvedBusinessesRoute, token: accessToken, queryParameters: {
      "get_images": getImages,
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
      (snapshot.data! as List<dynamic>).map((e) => Business.fromMap(e)).toList(),
    );
  }

  Future<AsyncSnapshot<Business>> updateBusinessApproval({
    required String businessId,
    required bool approved,
    required String note,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await post(subRoute: approveBusinessesRoute, token: accessToken, data: {
      "approved": approved,
      "note": note,
      'business_id': businessId,
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
