import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

enum Status { Loading, Done }

class AlertsProvider extends ChangeNotifier {
  static const String DB_NAME = "watcher.db";
  sqlite.Database _db;

  final String _coinId;

  List<Map> _alerts;
  List<Map> get alerts => _alerts;

  Status _status = Status.Loading;
  Status get status => _status;

  AlertsProvider(this._coinId) {
    sqlite.openDatabase(DB_NAME, version: 3).then((db) async {
      _db = db;

      _alerts = await _db.query(
        "user_alerts",
        where: "coin_id = ?",
        whereArgs: [_coinId],
      );
      _status = Status.Done;
      notifyListeners();
    });
  }

  addAlert(final double price) async {
    await _db.insert("user_alerts", {"coin_id": _coinId, "price": price});
    _alerts = await _db.query(
      "user_alerts",
      where: "coin_id = ?",
      whereArgs: [_coinId],
    );
    notifyListeners();
  }
}
