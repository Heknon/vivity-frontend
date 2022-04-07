class AuthResult {
  final String accessToken;
  final String refreshToken;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
  });

  AuthResult copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    if ((accessToken == null || identical(accessToken, this.accessToken)) && (refreshToken == null || identical(refreshToken, this.refreshToken))) {
      return this;
    }

    return new AuthResult(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  String toString() {
    return 'AuthResult{accessToken: $accessToken, refreshToken: $refreshToken}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthResult && runtimeType == other.runtimeType && accessToken == other.accessToken && refreshToken == other.refreshToken);

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode;

  factory AuthResult.fromMap(Map<String, dynamic> map) {
    return new AuthResult(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'access_token': this.accessToken,
      'refresh_token': this.refreshToken,
    } as Map<String, dynamic>;
  }
}