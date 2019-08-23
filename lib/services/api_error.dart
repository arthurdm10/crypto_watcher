import 'package:http/http.dart';

class ApiError implements Exception {
  String message;
  int statusCode;

  ApiError(final Response response)
      : statusCode = response.statusCode,
        message = response.body;
}
