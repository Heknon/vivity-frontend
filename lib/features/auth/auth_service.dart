import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/register_result.dart';
import 'package:vivity/services/api_service.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();

/// logs in and returns token. returning null signals login failed
Future<String?> login(String email, String password) async {
  http.Response res = await sendPostRequest(subRoute: "$userPath/login", data: {
    "email": email,
    "password": password,
  });

  if (res.statusCode != 200) {
    return null;
  }

  return jsonDecode(res.body)['token'];
}

Future<RegisterResult> register(String email, String password, String name, String phone) async {
  http.Response res = await sendPostRequest(
    subRoute: "$userPath/register",
    data: {
      "email": email,
      "password": password,
      "name": name,
      "phone": phone,
    },
  );

  Map<String, dynamic> decoded = jsonDecode(res.body);

  return RegisterResult(
    decoded.containsKey("token") ? decoded['token'] : null,
    decoded.containsKey("auth_result") ? AuthenticationResult.values[decoded['auth_result'] as int] : null,
  );
}

Future<bool> verifyToken(String token) async {
  http.Response res = await sendGetRequest(subRoute: "$userPath/verify?token=$token");
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
