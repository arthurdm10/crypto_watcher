import 'dart:async';

import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

enum Status { Loading, Done }

enum AlertType { PriceAbove, PriceBelow, PriceChangeBy }

class AlertsProvider {
  static const String DB_NAME = "watcher.db";
  static const String TABLE_NAME = "user_alerts";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final _runningTimers = Map<int, Timer>();
  sqlite.Database _db;

  AlertsProvider() {
    _initLocalNotification();

    sqlite.openDatabase(DB_NAME, version: 3).then((db) async {
      _db = db;
      final alerts = await db.query(TABLE_NAME);
      for (final alert in alerts) {
        _startAlertTimer(alert);
      }
    });
  }

  Future<List> getCoinAlerts(String coinId) {
    return _db.query(TABLE_NAME, where: "coin_id = ?", whereArgs: [coinId]);
  }

  addAlert(
    AlertType type,
    int interval,
    String coinId,
    String exchangeId,
    String pairId,
    String pairSymbol,
    double value,
    double currentValue,
  ) async {
    final alertData = {
      "type": type.index,
      "interval": interval,
      "coin_id": coinId,
      "pair_id": pairId,
      "pair_symbol": pairSymbol,
      "value": value,
      "current_value": currentValue,
      "exchange_id": exchangeId,
    };
    final alertId = await _db.insert(TABLE_NAME, alertData);
    alertData["id"] = alertId;
    _startAlertTimer(alertData);
  }

  deleteAlert(int id) async {
    await _db.delete(TABLE_NAME, where: "id = ?", whereArgs: [id.toString()]);
    _runningTimers[id].cancel();
    _runningTimers.remove(id);
  }

  /**
   *  delete all alerts for 'coinId'
   */
  deleteCoinAlerts(String coinId) async {
    final alerts = await getCoinAlerts(coinId);
    for (final alert in alerts) {
      _runningTimers[alert["id"]].cancel();
      _runningTimers.remove(alert["id"]);
    }
    await _db.delete(TABLE_NAME, where: "coin_id = ?", whereArgs: [coinId]);
  }

  _startAlertTimer(Map alert) {
    final alertTimer = Timer.periodic(
      Duration(minutes: alert["interval"]),
      (timer) => _alertRoutine(timer, alert),
    );

    _runningTimers[alert["id"]] = alertTimer;
  }

  _alertRoutine(Timer timer, Map alert) async {
    final completed = await _checkCoinPrice(alert);
    if (!completed) {
      return;
    }
    await deleteAlert(alert["id"]);
  }

  /**
   * get the current coin price and check if it satifies the condition
   */
  Future<bool> _checkCoinPrice(Map alertData) async {
    final response = await CoincapApi.markets(
      exchangeId: alertData["exchange_id"],
      baseId: alertData["coin_id"],
      quoteId: alertData["pair_id"],
    );

    final coinData = response["data"][0];
    final price = double.parse(coinData["priceQuote"]);
    final alertType = AlertType.values[alertData["type"]];
    bool completed = false;
    String msg;

    switch (alertType) {
      case AlertType.PriceAbove:
        completed = (price > alertData["value"]);
        msg =
            '${alertData["coin_id"]} is above ${alertData["value"]} ${alertData["pair_symbol"]} ';
        break;
      case AlertType.PriceBelow:
        completed = (price < alertData["value"]);
        msg =
            '${alertData["coin_id"]} is below ${alertData["value"]} ${alertData["pair_symbol"]} ';
        break;
      case AlertType.PriceChangeBy:
        final percentValue = alertData["value"];
        final currentPrice = alertData["current_value"];
        final percentPrice = currentPrice + currentPrice * (percentValue / 100);

        completed = (price >= percentPrice || price <= percentPrice);
        msg =
            '${alertData["coin_id"]} changed by ${alertData["value"]}%, it\'s $price ${alertData["pair_symbol"]} !';
        break;
    }

    if (completed) {
      await _showNotification(
        "Crypto Watcher",
        msg,
      );
    }

    return completed;
  }

  /**
   * Setup notification
   */
  _initLocalNotification() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  _showNotification(String title, String content) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channelId',
      'channelName',
      'channel description',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
    );
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, content, platformChannelSpecifics);
  }
}
