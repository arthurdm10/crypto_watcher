import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiRequest {
  static const String _baseUrl = "api.coincap.io:443";
  String _path;
  String _method;
  http.Client client = http.Client();

  String _body;
  Map<String, String> _queryParams, _headers = Map();

  ApiRequest get() {
    this._method = "GET";
    return this;
  }

  ApiRequest post() {
    this._method = "POST";
    return this;
  }

  ApiRequest delete() {
    this._method = "DELETE";
    return this;
  }

  ApiRequest headers(Map<String, String> headers) {
    this._headers = headers;
    return this;
  }

  ApiRequest body(Map<String, dynamic> body) {
    this._body = json.encode(body);
    return this;
  }

  ApiRequest queryParams(Map<String, String> params) {
    this._queryParams = params;
    return this;
  }

  ApiRequest path(String path) {
    this._path = path;
    return this;
  }

  Future<http.Response> send() {
    assert(_path != null);
    assert(_method != null);

    final httpUrl = Uri.https(_baseUrl, _path, _queryParams);
    var response;

    if (_method == "GET") {
      response = client.get(httpUrl, headers: _headers);
    } else if (_method == "POST") {
      _headers["content-type"] ??= "application/json";
      response = client.post(httpUrl, headers: _headers, body: _body);
    } else if (_method == "DELETE") {
      response = client.delete(httpUrl, headers: _headers);
    }

    return response;
  }
}
