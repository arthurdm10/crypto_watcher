import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/pages/add_coin.dart';
import 'package:crypto_watcher/pages/coin_info/coin_info.dart';
import 'package:crypto_watcher/providers/alert_provider.dart';
import 'package:crypto_watcher/providers/coins_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coins = Provider.of<CoinsProvider>(context);
    final alerts = Provider.of<AlertsProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          tooltip: "Add a coin to your watch list!",
          onPressed: () async {
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
        body: Container(
          margin: const EdgeInsets.only(top: 15),
          child: FutureBuilder(
            future: coins.fetchUserCoinsData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: LoadingIndicator());
              }
              final coinsData = snapshot.data;
              return RefreshIndicator(
                color: AppColors.secondaryColor,
                backgroundColor: AppColors.backgroundLight,
                onRefresh: () async => coins.refresh(),
                child: ListView(
                  children: ListTile.divideTiles(
                    color: AppColors.backgroundLight,
                    tiles: coinsData.map<Widget>(
                      (coin) {
                        final coinSymbol = coin["symbol"];
                        final coinUsdPrice =
                            double.parse(coin["priceUsd"]).toStringAsFixed(2);

                        final coin24hChange =
                            double.parse(coin["changePercent24Hr"]);
                        final coinChangeDecrease = coin24hChange < 0;

                        final percentChangeColor =
                            coinChangeDecrease ? Colors.red : Colors.green;

                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          dismissThresholds: {DismissDirection.endToStart: 0.3},
                          onDismissed: (_) async {
                            await coins.removeCoin(coin["id"], notify: false);
                            await alerts.deleteCoinAlerts(coin["id"]);
                          },
                          resizeDuration: Duration(milliseconds: 80),
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider.value(value: coins),
                                    Provider.value(value: alerts),
                                  ],
                                  child: CoinInfo(
                                    coin["id"],
                                    coinSymbol,
                                    coin["name"],
                                  ),
                                ),
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
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
                                  'assets/icons/${coinSymbol.toLowerCase()}.png'),
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '\$$coinUsdPrice',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      '${(coinChangeDecrease ? "" : "+")}${coin24hChange.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        color: percentChangeColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Icon(
                                      coinChangeDecrease
                                          ? Icons.arrow_drop_down
                                          : Icons.arrow_drop_up,
                                      color: percentChangeColor,
                                      size: 17,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
