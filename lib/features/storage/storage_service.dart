import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _storageService = StorageService._();

  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static const String refreshTokenKey = "refresh_token";
  static const String previouslyLoggedInKey = 'previously_logged_in';

  StorageService._();

  factory StorageService() {
    return _storageService;
  }

  Future<void> storeRefreshToken(String refreshToken) async {
    await _store(refreshTokenKey, refreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _delete(refreshTokenKey);
  }

  Future<String?> getRefreshToken() async {
    AsyncSnapshot<String?> snapshot = await _read(refreshTokenKey);

    if (snapshot.hasError || !snapshot.hasData) {
      return null;
    }

    return snapshot.data;
  }

  Future<bool> getPreviouslyLoggedIn() async {
    AsyncSnapshot<String?> snapshot = await _read(previouslyLoggedInKey);

    if (snapshot.hasError || !snapshot.hasData) {
      return false;
    }

    return snapshot.data == '1';
  }

  Future<void> setPreviouslyLoggedIn({bool previouslyLoggedIn = true}) async {
    await _store(previouslyLoggedInKey, previouslyLoggedIn ? '1' : '0');
  }

  Future<void> _store(String key, String value) async {
    await storage.write(key: key, value: value, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
  }

  Future<void> _delete(String key) async {
    await storage.delete(key: key, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
  }

  Future<AsyncSnapshot<String>> _read(String key) async {
    try {
      String? value = await storage.read(key: key, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
      if (value == null) return AsyncSnapshot.nothing();
      return AsyncSnapshot.withData(ConnectionState.done, value);
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  IOSOptions _getIOSOptions() => const IOSOptions();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}
