import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/pages/add_coin.dart';
import 'package:crypto_watcher/pages/coin_info/coin_info.dart';
import 'package:crypto_watcher/providers/coins.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coins = Provider.of<Coins>(context);
    return SafeArea(
      child: Scaffold(
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
            future: coins.fetchCoinsData(),
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

                        return Dismissible(
                          key: GlobalKey(),
                          direction: DismissDirection.endToStart,
                          dismissThresholds: {DismissDirection.endToStart: 0.3},
                          onDismissed: (_) {
                            coins.removeCoin(coin["id"]);
                          },
                          resizeDuration: Duration(milliseconds: 80),
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: coins,
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
                                    color: coin24hChange < 0
                                        ? Colors.red
                                        : Colors.green,
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
