class TokenContainer {
  final String accessToken;
  final String refreshToken;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const TokenContainer({
    required this.accessToken,
    required this.refreshToken,
  });

  TokenContainer copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    if ((accessToken == null || identical(accessToken, this.accessToken)) && (refreshToken == null || identical(refreshToken, this.refreshToken))) {
      return this;
    }

    return new TokenContainer(
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
      (other is TokenContainer && runtimeType == other.runtimeType && accessToken == other.accessToken && refreshToken == other.refreshToken);

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode;

  factory TokenContainer.fromMap(Map<String, dynamic> map) {
    return new TokenContainer(
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