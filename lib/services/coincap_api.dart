import 'dart:convert';
import 'dart:io';

import 'package:crypto_watcher/services/api_error.dart';
import 'package:crypto_watcher/services/base_request/api_request.dart';
import 'package:flutter/widgets.dart';

class CoincapApi {
  static Future<Map> assets({
    String assetId,
    String searchId,
    List<String> ids,
    int limit = 20,
    int offset = 0,
  }) async {
    final path = '/v2/assets/' + (assetId == null ? '' : assetId);

    final Map<String, String> query = {
      "limit": limit.toString(),
      "offset": offset.toString(),
    };

    if (searchId != null && searchId.isNotEmpty) {
      query["search"] = searchId;
    }

    if (ids != null && ids.isNotEmpty) {
      query["ids"] = ids.join(",");
    }

    final res = await ApiRequest().get().path(path).queryParams(query).send();
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body);
    }

    throw ApiError(res);
  }

  static Future<Map> assetHistory(
    String assetId,
    String interval, {
    int start,
    int end,
  }) async {
    assert(assetId != null);
    assert(interval != null);

    Map<String, String> query = {"interval": interval};

    if (start != null || end != null) {
      assert(start != null);
      assert(end != null);

      query["start"] = start.toString();
      query["end"] = end.toString();
    }

    final res = await ApiRequest()
        .get()
        .path('/v2/assets/$assetId/history')
        .queryParams(query)
        .send();
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body);
    }

    throw ApiError(res);
  }

  static Future<Map> exchanges({String exchangeId}) async {
    final path = '/v2/exchanges/' + (exchangeId == null ? '' : exchangeId);

    final res = await ApiRequest().get().path(path).send();
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body);
    }

    throw ApiError(res);
  }

  static Future<Map> markets({
    String exchangeId,
    String baseId,
    String quoteId,
  }) async {
    final Map<String, String> query = {
      "exchangeId": exchangeId ?? '',
      "baseId": baseId ?? '',
      "quoteId": quoteId ?? '',
    };

    final res =
        await ApiRequest().get().path('/v2/markets/').queryParams(query).send();
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body);
    }

    throw ApiError(res);
  }

  static Future<Map> candles(
      {@required String exchangeId,
      @required String interval,
      @required String baseId,
      @required String quoteId,
      int start,
      int end}) async {
    Map<String, String> query = {
      "exchange": exchangeId,
      "interval": interval,
      "baseId": baseId,
      "quoteId": quoteId,
    };

    if (start != null || end != null) {
      assert(start != null);
      assert(end != null);

      query["start"] = start.toString();
      query["end"] = end.toString();
    }

    final res =
        await ApiRequest().get().path('/v2/candles').queryParams(query).send();
    if (res.statusCode == HttpStatus.ok) {
      return jsonDecode(res.body);
    }

    throw ApiError(res);
  }
}
