import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/auth_result.dart';
import 'package:vivity/features/auth/register_result.dart';
import 'package:vivity/services/api_service.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();
RSAPublicKey? jwtPublicRefreshKey;
RSAPublicKey? jwtPublicAccessKey;

/// logs in and returns token. returning null signals login failed
Future<RegisterResult?> login(String email, String password, String? otp, void Function(Response)? onFail) async {
  Response res = await sendPostRequest(subRoute: "$userRoute/login", data: {
    "email": email,
    "password": password,
    "otp": otp,
  });

  if (res.statusCode != 200) {
    if (onFail != null) onFail(res);
    return RegisterResult(
      authResult: null,
      authStatus: res.data['data'] != null ? AuthenticationResult.values[res.data['data']] : null,
    );
    ;
  }

  return RegisterResult(
    authResult: AuthResult.fromMap(res.data),
    authStatus: AuthenticationResult.success,
  );
}

Future<RegisterResult> register(String email, String password, String name, String phone) async {
  Response res = await sendPostRequest(
    subRoute: "$userRoute/register",
    data: {
      "email": email,
      "password": password,
      "name": name,
      "phone": phone,
    },
  );

  return RegisterResult(
    authResult: AuthResult.fromMap(res.data),
    authStatus: res.data.containsKey("auth_result") ? AuthenticationResult.values[res.data['auth_result'] as int] : null,
  );
}

Future<bool> hasOTP({String? email, String? id}) async {
  assert(email != null || id != null, "Must pass email or id");

  String route = userOtpRoute;
  if (id != null) route += "?id=$id";
  else if (email != null) route += "?email=$email";

  Response res = await sendGetRequest(subRoute: route);

  if (res.statusCode! > 300) {
    return false;
  }

  return res.data['enabled'];
}

Future<AuthResult?> refreshAccessToken(String refreshToken) async {
  if (!isRefreshTokenValid(refreshToken)) return null;

  Response res = await sendGetRequest(subRoute: "$refreshAccessTokenRoute?token=$refreshToken");

  if (res.statusCode != 200) {
    return null;
  }

  return AuthResult.fromMap(res.data);
}

Future<AuthResult?> refreshRefreshToken(String refreshToken) async {
  if (!isRefreshTokenValid(refreshToken)) return null;

  Response res = await sendGetRequest(subRoute: "$refreshRefreshTokenRoute?token=$refreshToken");

  if (res.statusCode != 200) {
    return null;
  }

  return AuthResult.fromMap(res.data);
}

void securelyStoreCredentials(String refreshToken) {
  storage.write(key: "refresh_token", value: refreshToken, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
}

void eraseCredentialsFromStorage() {
  storage.delete(key: "refresh_token", iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
}

Future<String?> getStoredCredential(String key) async {
  return storage.read(key: key, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
}

Future<String?> getStoredRefreshToken() {
  return getStoredCredential("refresh_token");
}

IOSOptions _getIOSOptions() => const IOSOptions();

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

Future<void> loadJwtPublicKey() async {
  Response res = await sendGetRequest(subRoute: apiJwtPublicKey);

  if (res.statusCode! > 200) throw Exception('Failed to receive public jwt key');

  jwtPublicAccessKey = RSAPublicKey(res.data['access_key']);
  jwtPublicRefreshKey = RSAPublicKey(res.data['refresh_key']);
}

JWT? parseToken(String token, RSAPublicKey? key) {
  if (key == null) return null;

  try {
    return JWT.verify(token, key);
  } catch (e) {
    return null;
  }
}

bool isTokenValid(String token, RSAPublicKey? key) => parseToken(token, key) != null;

JWT? parseAccessToken(String token) => parseToken(token, jwtPublicAccessKey);

JWT? parseRefreshToken(String token) => parseToken(token, jwtPublicRefreshKey);

bool isAccessTokenValid(String token) => isTokenValid(token, jwtPublicAccessKey);

bool isRefreshTokenValid(String token) => isTokenValid(token, jwtPublicRefreshKey);
