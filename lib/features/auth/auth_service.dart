import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();

/// logs in and returns token. returning null signals login failed
Future<String?> login(String email, String password) async {
  return "null";
}

Future<String?> register(String email, String password, String name, String phone) async {
  return null;
}

Future<bool> verifyToken(String token) async {
  return false;
}

void securelyStoreCredentials(String email, String password) {
  storage.write(key: "auth_email", value: email, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
  storage.write(key: "auth_pw", value: password, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
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
