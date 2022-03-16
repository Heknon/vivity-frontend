import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vivity/services/api_service.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getUserFromToken(String token) async {
  if (JwtDecoder.isExpired(token)) return null;

  http.Response response = await sendGetRequest(subRoute: "/user", token: token);
  // TODO: Must implement ASAP in order to enable login
  //Map<String, dynamic> userInfo = response.body;
}

Map<String, dynamic>? getUserFromId(List<int> id) {

}