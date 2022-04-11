import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtKeyContainer {
  final RSAPublicKey accessKey;
  final RSAPublicKey refreshKey;

//<editor-fold desc="Data Methods">

  const JwtKeyContainer({
    required this.accessKey,
    required this.refreshKey,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JwtKeyContainer && runtimeType == other.runtimeType && accessKey == other.accessKey && refreshKey == other.refreshKey);

  @override
  int get hashCode => accessKey.hashCode ^ refreshKey.hashCode;

  @override
  String toString() {
    return 'JwtKeyContainer{' + ' accessKey: $accessKey,' + ' refreshKey: $refreshKey,' + '}';
  }

  JwtKeyContainer copyWith({
    RSAPublicKey? accessKey,
    RSAPublicKey? refreshKey,
  }) {
    return JwtKeyContainer(
      accessKey: accessKey ?? this.accessKey,
      refreshKey: refreshKey ?? this.refreshKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessKey': this.accessKey,
      'refreshKey': this.refreshKey,
    };
  }

  factory JwtKeyContainer.fromMap(Map<String, dynamic> map) {
    return JwtKeyContainer(
      accessKey: map['accessKey'] as RSAPublicKey,
      refreshKey: map['refreshKey'] as RSAPublicKey,
    );
  }

//</editor-fold>
}