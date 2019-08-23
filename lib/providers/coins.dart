import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Coins extends ChangeNotifier {
  SharedPreferences pref;
  List<String> userCoins;
  Map<String, Map<String, dynamic>> loadedCoins;
  DateTime _cacheTimeExp;

  Future loadPreferences() async {
    loadedCoins = Map<String, Map<String, dynamic>>();
    pref = await SharedPreferences.getInstance();
    userCoins = pref.getStringList("coins");
    // final res = await CoincapApi.assets(ids: userCoins);
    // loadedCoins = res["data"];
  }

  Future<Map<String, dynamic>> fetchCoinsData() async {
    _cacheTimeExp = DateTime.now().add(Duration(seconds: 30));
    final coinData = await CoincapApi.assets(ids: userCoins);
    return coinData["data"];
  }

  void addCoin(final String coinId) async {
    userCoins.add(coinId);
    await pref.setStringList("coins", userCoins);
    notifyListeners();
  }

  void removeCoin(final String coinId) async {
    userCoins.remove(coinId);
    await pref.setStringList("coins", userCoins);
    notifyListeners();
  }
}
