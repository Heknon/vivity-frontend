import 'package:jwt_decoder/jwt_decoder.dart';

Map<String, dynamic>? getUserFromToken(String token) {
  if (JwtDecoder.isExpired(token)) return null;

  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
}