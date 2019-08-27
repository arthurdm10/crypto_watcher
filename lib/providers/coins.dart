import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Coins extends ChangeNotifier {
  SharedPreferences pref;
  List<String> userCoins;
  Map<String, Map<String, dynamic>> loadedCoins;

  Map<String, Map<String, dynamic>> exchanges;

  Coins() {
    CoincapApi.exchanges().then((response) => exchanges = Map.fromIterable(
        response["data"],
        key: (ex) => ex["exchangeId"],
        value: (ex) => ex));
  }

  Future loadPreferences() async {
    loadedCoins = Map<String, Map<String, dynamic>>();
    pref = await SharedPreferences.getInstance();
    userCoins = pref.getStringList("coins");
  }

  Future fetchCoinsData() async {
    if (userCoins.isNotEmpty) {
      final coinData = await CoincapApi.assets(ids: userCoins);
      return coinData["data"];
    }
    return [];
  }

  Future fetchCoinData(String coinId) async {
    final coinData = await CoincapApi.assets(assetId: coinId);
    return coinData["data"];
  }

  void refresh() => this.notifyListeners();

  void addCoin(final String coinId) async {
    userCoins.add(coinId);
    await pref.setStringList("coins", userCoins);
    notifyListeners();
  }

  void removeCoin(final String coinId) async {
    userCoins.remove(coinId);
    await pref.setStringList("coins", userCoins);
    // notifyListeners();
  }
}
