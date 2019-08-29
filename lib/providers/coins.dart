import 'dart:async';

import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

class Coins extends ChangeNotifier {
  static const String DB_NAME = "watcher.db";

  List<Map> userCoins;
  Map<String, Map<String, dynamic>> loadedCoins;

  Map<String, Map<String, dynamic>> exchanges;

  sqlite.Database db;

  Future _createDb(sqlite.Database db, int v) async {
    await db.execute('''
      CREATE TABLE user_coins(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            coin_id TEXT NOT NULL,
            coin_name TEXT NOT NULL,
            coin_symbol TEXT NOT NULL);
    ''');
    await db.execute('''
      CREATE TABLE user_alerts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value REAL NOT NULL,
            type INTEGER NOT NULL,
            interval INTEGER NOT NULL,
            exchange_id TEXT NOT NULL,
            coin_id TEXT NOT NULL,
            pair_id TEXT NOT NULL,
            pair_symbol TEXT NOT NULL,
            current_value REAL NOT NULL
            );
    ''');
  }

  Coins() {
    CoincapApi.exchanges().then(
      (response) => exchanges = Map.fromIterable(
        response["data"],
        key: (ex) => ex["exchangeId"],
        value: (ex) => ex,
      ),
    );
  }

  Future loadDb() async {
    db = await sqlite.openDatabase(DB_NAME, onCreate: _createDb, version: 3);
    userCoins = await db.query("user_coins");
  }

  Future fetchCoinsData() async {
    if (userCoins.isNotEmpty) {
      final coinData = await CoincapApi.assets(
          ids: userCoins.map<String>((coin) => coin["coin_id"]).toList());
      return coinData["data"];
    }
    return [];
  }

  Future fetchCoinData(String coinId) async {
    final coinData = await CoincapApi.assets(assetId: coinId);
    return coinData["data"];
  }

  void refresh() => this.notifyListeners();

  void addCoin(Map coin) async {
    await db.insert("user_coins", {
      "coin_id": coin["id"],
      "coin_name": coin["name"],
      "coin_symbol": coin["symbol"],
    });
    userCoins = await db.query("user_coins");
    notifyListeners();
  }

  removeCoin(final String coinId, {final bool notify = true}) async {
    await db.delete("user_coins", where: "coin_id = ?", whereArgs: [coinId]);
    userCoins = await db.query("user_coins");
    if (notify) {
      notifyListeners();
    }
  }
}
