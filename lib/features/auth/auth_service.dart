import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/register_result.dart';
import 'package:vivity/services/api_service.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();

/// logs in and returns token. returning null signals login failed
Future<String?> login(String email, String password) async {
  Response res = await sendPostRequest(subRoute: "$userRoute/login", data: {
    "email": email,
    "password": password,
  });

  if (res.statusCode != 200) {
    return null;
  }

  return res.data['token'];
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
    res.data.containsKey("token") ? res.data['token'] : null,
    res.data.containsKey("auth_result") ? AuthenticationResult.values[res.data['auth_result'] as int] : null,
  );
}

Future<bool> verifyToken(String token) async {
  Response res = await sendGetRequest(subRoute: "$userRoute/verify?token=$token");
  return res.statusCode == 200;
}

void securelyStoreCredentials(String email, String password) {
  storage.write(key: "auth_email", value: email, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
  storage.write(key: "auth_pw", value: password, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
}

void eraseCredentialsFromStorage() {
  storage.delete(key: "auth_email", iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
  storage.delete(key: "auth_pw", iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
}

Future<String?> getStoredCredential(String key) async {
  return storage.read(key: key, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
}

Future<String?> getStoredPassword() {
  return getStoredCredential("auth_pw");
}

Future<String?> getStoredEmail() {
  return getStoredCredential("auth_email");
}

IOSOptions _getIOSOptions() => const IOSOptions();

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
