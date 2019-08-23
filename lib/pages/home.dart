import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/pages/add_coin.dart';
import 'package:crypto_watcher/providers/coins.dart';
import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;

class HomePage extends StatelessWidget {
  List<String> _userCoins;
  @override
  Widget build(BuildContext context) {
    final coins = Provider.of<Coins>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          color: AppColors.backgroundLight,
          height: 40,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: "Add a coin to your watch list!",
        onPressed: () async {
          final pref = await SharedPreferences.getInstance();
          // await pref.remove("coins");

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: coins,
                child: AddCoin(),
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: FutureBuilder(
        future: coins.fetchCoinsData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingIndicator());
          }
          final coinsData = snapshot.data;
          return ListView(
            children: ListTile.divideTiles(
              color: AppColors.backgroundLight,
              tiles: coinsData.map<Widget>(
                (coin) {
                  final coinSymbol = coin["symbol"];
                  final coinUsdPrice =
                      double.parse(coin["priceUsd"]).toStringAsFixed(2);

                  final coin24hChange = double.parse(coin["changePercent24Hr"]);

                  return Dismissible(
                    key: GlobalKey(),
                    direction: DismissDirection.endToStart,
                    dismissThresholds: {DismissDirection.endToStart: 0.3},
                    onDismissed: (_) {
                      coins.removeCoin(coin["id"]);
                    },
                    child: ListTile(
                      title: Text(
                        '${coin["name"]}',
                        style: TextStyle(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '$coinSymbol',
                        style: TextStyle(
                            color: AppColors.secondaryDark.withAlpha(200),
                            fontSize: 11),
                      ),
                      leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                            'assets/icons/${coin["symbol"].toLowerCase()}.png'),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '\$$coinUsdPrice',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '${(coin24hChange < 0 ? "" : "+")}${coin24hChange.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: coin24hChange < 0 ? Colors.red : Colors.green,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ).toList(),
          );
        },
      ),
    );
  }
}
