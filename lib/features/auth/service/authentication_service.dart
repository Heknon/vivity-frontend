import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/models/authentication_result.dart';
import 'package:vivity/features/auth/models/jwt_key_container.dart';
import 'package:vivity/features/auth/models/token_container.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/services/service_provider.dart';

class AuthenticationService extends ServiceProvider {
  static final AuthenticationService _authenticationService = AuthenticationService._();
  static final AuthenticationRepository _authRepository = AuthenticationRepository();

  static const String loginSubRoute = '/login';
  static const String registerSubRoute = '/register';
  static const String logoutSubRoute = '/logout'; // TODO: Create logout route on backend
  static const String otpSubRoute = '/otp';
  static const String refreshAccessTokenSubRoute = '/refresh';
  static const String refreshRefreshTokenSubRoute = '/refresh/refresh';
  static const String jwtPublicKeysRoute = '/jwt/public';

  AuthenticationService._() : super(baseRoute: authRoute);

  factory AuthenticationService() {
    return _authenticationService;
  }

  Future<AsyncSnapshot<AuthenticationResult>> login({
    required String email,
    required String password,
    required String? otp,
  }) async {
    AsyncSnapshot<Response> snapshot = await post(subRoute: loginSubRoute, data: {
      "email": email,
      "password": password,
      "otp": otp,
    });

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withData(
        ConnectionState.done,
        AuthenticationResult(
          authStatus: response.data['data'] != null ? AuthenticationStatus.values[response.data['data']] : AuthenticationStatus.emailIncorrect,
        ),
      );
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      AuthenticationResult(
        tokenContainer: TokenContainer.fromMap(response.data),
        authStatus: AuthenticationStatus.success,
      ),
    );
  }

  Future<AsyncSnapshot<AuthenticationResult>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    AsyncSnapshot<Response> snapshot = await post(subRoute: registerSubRoute, data: {
      "email": email,
      "password": password,
      "name": name,
      "phone": phone,
    });

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withData(
        ConnectionState.done,
        AuthenticationResult(authStatus: AuthenticationStatus.values[(response.data['auth_status'] ?? 0)]),
      );
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      AuthenticationResult(
        tokenContainer: TokenContainer.fromMap(response.data),
        authStatus: AuthenticationStatus.success,
      ),
    );
  }

  Future<AsyncSnapshot> logout() async {
    AsyncSnapshot<Response> snapshot = await post(subRoute: logoutSubRoute);

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.nothing();
  }

  Future<AsyncSnapshot<bool>> hasOTP({
    String? email,
    String? id,
  }) async {
    assert(email != null || id != null, "Must pass email or id");

    String params = "";
    if (id != null) params += "${params.isNotEmpty ? "&" : ""}id=$id";
    if (email != null) params += "${params.isNotEmpty ? "&" : ""}email=$email";
    AsyncSnapshot<Response> snapshot = await get(subRoute: otpSubRoute + "?$params");

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withData(
        ConnectionState.done,
        false,
      );
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      response.data['enabled'] ?? false,
    );
  }

  Future<AsyncSnapshot<String>> enableOTP() async {
    AsyncSnapshot<Response> snapshot = await post(subRoute: otpSubRoute, token: await _authRepository.getAccessToken());
    snapshot = checkFaultyAndTransformResponse(snapshot);

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    return AsyncSnapshot.withData(
      ConnectionState.done,
      response.data['secret'],
    );
  }

  Future<AsyncSnapshot<bool>> disableOTP() async {
    AsyncSnapshot<Response> snapshot = await delete(subRoute: otpSubRoute, token: await _authRepository.getAccessToken());
    snapshot = checkFaultyAndTransformResponse(snapshot);

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.withData(ConnectionState.done, false);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      false,
    );
  }

  Future<AsyncSnapshot<AuthenticationResult>> refreshAccessToken({
    required String refreshToken,
  }) async {
    AsyncSnapshot<Response> snapshot = await get(subRoute: refreshAccessTokenSubRoute + "?token=$refreshToken");

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withData(
        ConnectionState.done,
        AuthenticationResult(
          authStatus: AuthenticationStatus.emailIncorrect,
        ),
      );
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      AuthenticationResult(
        tokenContainer: TokenContainer.fromMap(response.data),
        authStatus: AuthenticationStatus.success,
      ),
    );
  }

  Future<AsyncSnapshot<AuthenticationResult>> refreshRefreshToken({
    required String refreshToken,
  }) async {
    AsyncSnapshot<Response> snapshot = await get(subRoute: refreshRefreshTokenSubRoute + "?token=$refreshToken");

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withData(
        ConnectionState.done,
        AuthenticationResult(
          authStatus: AuthenticationStatus.emailIncorrect,
        ),
      );
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      AuthenticationResult(
        tokenContainer: TokenContainer.fromMap(response.data),
        authStatus: AuthenticationStatus.success,
      ),
    );
  }

  Future<AsyncSnapshot<JwtKeyContainer>> getPublicJwtKeys() async {
    AsyncSnapshot<Response> snapshot = await get(baseRoute: jwtPublicKeysRoute);

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(
        ConnectionState.done,
        response.data['error'],
      );
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      JwtKeyContainer(
        accessKey: RSAPublicKey(response.data['access_key']),
        refreshKey: RSAPublicKey(response.data['refresh_key']),
      ),
    );
  }
}
