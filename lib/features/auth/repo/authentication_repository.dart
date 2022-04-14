import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/features/auth/models/authentication_result.dart';
import 'package:vivity/features/auth/errors/auth_exceptions.dart';
import 'package:vivity/features/auth/models/jwt_key_container.dart';
import 'package:vivity/features/auth/models/token_container.dart';
import 'package:vivity/features/storage/storage_service.dart';
import 'package:vivity/features/user/service/user_service.dart';

import '../service/authentication_service.dart';

class AuthenticationRepository {
  static final AuthenticationRepository _authenticationRepository = AuthenticationRepository._();

  final AuthenticationService _authService = AuthenticationService();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  JwtKeyContainer? _keyContainer;
  String? _accessToken;
  String? _refreshToken;
  bool? _previouslyLoggedIn;
  bool? _hasOTP;

  AuthenticationRepository._();

  factory AuthenticationRepository() {
    return _authenticationRepository;
  }

  Future<TokenContainer> login({
    required String email,
    required String password,
    required String? otp,
  }) async {
    AsyncSnapshot<AuthenticationResult> snapshot = await _authService.login(
      email: email,
      password: password,
      otp: otp,
    );

    if (snapshot.hasError || !snapshot.hasData || snapshot.data?.tokenContainer == null) {
      throw AuthFailedException(
        response: snapshot.error is Response ? snapshot.error as Response : null,
        message: snapshot.data?.authStatus?.getMessage() ?? "Authentication failed",
      );
    }

    TokenContainer tokenContainer = snapshot.data!.tokenContainer!;
    _accessToken = tokenContainer.accessToken;
    _refreshToken = tokenContainer.refreshToken;
    return tokenContainer;
  }

  Future<TokenContainer> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    AsyncSnapshot<AuthenticationResult> snapshot = await _authService.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    if (snapshot.hasError || !snapshot.hasData || snapshot.data?.tokenContainer == null) {
      throw AuthFailedException(
        response: snapshot.error is Response ? snapshot.error as Response : null,
        message: snapshot.data?.authStatus?.getMessage() ?? "Authentication failed",
      );
    }

    TokenContainer tokenContainer = snapshot.data!.tokenContainer!;
    _accessToken = tokenContainer.accessToken;
    _refreshToken = tokenContainer.refreshToken;
    return tokenContainer;
  }

  Future<String> enableOTP() async {
    AsyncSnapshot<String> snapshot = await _authService.enableOTP();

    if (snapshot.hasError || !snapshot.hasData) {
      throw AuthFailedException(
        response: snapshot.error is Response ? snapshot.error as Response : null,
        message: snapshot.error is Response ? (snapshot.error as Response).data['error'] : null,
      );
    }

    return snapshot.data!;
  }

  Future<bool> disableOTP() async {
    AsyncSnapshot<bool> snapshot = await _authService.disableOTP();

    if (snapshot.hasError || !snapshot.hasData) {
      throw AuthFailedException(
        response: snapshot.error is Response ? snapshot.error as Response : null,
        message: snapshot.error is Response ? (snapshot.error as Response).data['error'] : null,
      );
    }

    return snapshot.data!;
  }

  Future<String> changePassword({
    required String password,
    required String newPassword,
  }) async {
    AsyncSnapshot<String> snapshot = await _userService.changePassword(password: password, newPassword: newPassword);

    if (snapshot.hasError || !snapshot.hasData) {
      throw AuthFailedException(
        response: snapshot.error is Response ? snapshot.error as Response : null,
        message: snapshot.error is Response ? (snapshot.error as Response).data['error'] : null,
      );
    }

    String accessToken = snapshot.data!;
    _accessToken = accessToken;
    return _accessToken!;
  }

  void setTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _hasOTP = null;
  }

  Future<JwtKeyContainer> getKeyContainer({bool update = false}) async {
    if (_keyContainer != null && !update) return _keyContainer!;

    AsyncSnapshot<JwtKeyContainer> snapshot = await _authService.getPublicJwtKeys();
    if (snapshot.hasError || !snapshot.hasData) throw Exception('Failed to get public JWT keys');

    _keyContainer = snapshot.data!;
    return _keyContainer!;
  }

  Future<String> getAccessToken({bool update = false}) async {
    if (_accessToken == null || (_accessToken?.isEmpty ?? true) || !(await _isAccessTokenValid(_accessToken ?? "")) || update) {
      // token invalid try to get new one
      AsyncSnapshot<AuthenticationResult> snapshot = await _authService.refreshAccessToken(refreshToken: await getRefreshToken());
      if (snapshot.hasError || !snapshot.hasData || (snapshot.data != null && snapshot.data?.tokenContainer == null)) {
        throw InvalidAccessToken();
      }

      TokenContainer container = snapshot.data!.tokenContainer!;
      _accessToken = container.accessToken;
      _refreshToken = container.refreshToken;

      if (!(await _isAccessTokenValid(_accessToken ?? ""))) {
        throw InvalidAccessToken();
      } else if (!(await _isRefreshTokenValid(_refreshToken ?? ""))) {
        throw InvalidRefreshToken();
      }
    }

    return _accessToken!;
  }

  Future<String> getRefreshToken({bool update = false}) async {
    if (_refreshToken == null || !(await _isRefreshTokenValid(_refreshToken ?? '')) || update) {
      _refreshToken = await _storageService.getRefreshToken();

      if (_refreshToken == null || !(await _isRefreshTokenValid(_refreshToken ?? ''))) throw InvalidRefreshToken();
    }

    return _refreshToken!;
  }

  Future<bool> hasOTP({bool update = false}) async {
    if (_hasOTP != null && !update) return _hasOTP!;

    String accessToken = await getAccessToken();
    JWT parsedToken = (await _parseAccessToken(accessToken))!;
    AsyncSnapshot<bool> snapshot = await _authService.hasOTP(id: parsedToken.payload['id']);
    if (snapshot.hasError || !snapshot.hasData) {
      return false;
    }

    return snapshot.data ?? false;
  }

  Future<bool> getPreviouslyLoggedIn({bool update = false}) async {
    if (_previouslyLoggedIn != null && !update) return _previouslyLoggedIn!;
    _previouslyLoggedIn = await _storageService.getPreviouslyLoggedIn();

    return _previouslyLoggedIn!;
  }

  JWT? _parseToken(String token, RSAPublicKey? key) {
    if (key == null) return null;

    try {
      return JWT.verify(token, key);
    } catch (e) {
      return null;
    }
  }

  bool _isTokenValid(String token, RSAPublicKey? key) => _parseToken(token, key) != null;

  Future<JWT?> _parseAccessToken(String token) async => _parseToken(token, (await getKeyContainer()).accessKey);

  Future<JWT?> _parseRefreshToken(String token) async => _parseToken(token, (await getKeyContainer()).refreshKey);

  Future<bool> _isAccessTokenValid(String token) async => _isTokenValid(token, (await getKeyContainer()).accessKey);

  Future<bool> _isRefreshTokenValid(String token) async => _isTokenValid(token, (await getKeyContainer()).refreshKey);
}
