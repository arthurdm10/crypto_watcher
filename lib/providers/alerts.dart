import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

enum Status { Loading, Done }

class AlertsProvider extends ChangeNotifier {
  static const String DB_NAME = "watcher.db";
  sqlite.Database _db;

  final String coinId;
  final String coinSymbol;

  List<Map> _alerts;
  List<Map> get alerts => _alerts;

  Status _status = Status.Loading;
  Status get status => _status;

  AlertsProvider(this.coinId, this.coinSymbol) {
    sqlite.openDatabase(DB_NAME, version: 3).then((db) async {
      _db = db;

      _alerts = await _db.query(
        "user_alerts",
        where: "coin_id = ?",
        whereArgs: [coinId],
      );
      _status = Status.Done;
      notifyListeners();
    });
  }

  addAlert(final double price) async {
    await _db.insert("user_alerts", {"coin_id": coinId, "price": price});
    _alerts = await _db.query(
      "user_alerts",
      where: "coin_id = ?",
      whereArgs: [coinId],
    );
    notifyListeners();
  }
}
