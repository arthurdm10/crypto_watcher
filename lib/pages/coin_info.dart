import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;
import 'package:flutter/material.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';

class CoinInfo extends StatelessWidget {
  final String _coinId;
  final String _coinSymbol;
  final String _coinName;
  CoinInfo(this._coinId, this._coinSymbol, this._coinName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(_coinName),
        backgroundColor: AppColors.backgroundColor,
        leading: SizedBox(
          width: 20,
          height: 20,
          child: Image.asset('assets/icons/${_coinSymbol.toLowerCase()}.png'),
        ),
      ),
      body: Container(
          margin: const EdgeInsets.only(top: 5),
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                child: FutureBuilder(
                  future: CoincapApi.candles(
                    exchangeId: "poloniex",
                    baseId: _coinId,
                    quoteId: "bitcoin",
                    interval: "h4",
                  ),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: LoadingIndicator());
                    }
                    final data = snapshot.data["data"];
                    return OHLCVGraph(
                      data: data,
                      enableGridLines: false,
                      volumeProp: 0.5,
                    );
                  },
                ),
              )
            ],
          )),
    );
  }
}
