import 'package:crypto_watcher/utils.dart';
import 'package:flutter/material.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;

class PairData extends StatelessWidget {
  final Map _data;

  const PairData(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Container();
    }
    final quotePriceStr = formatQuotePrice(_data["priceQuote"]);

    return Container(
      margin: const EdgeInsets.only(left: 5, top: 2),
      child: Column(
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: '\$${double.parse(_data["priceUsd"]).toStringAsFixed(2)}\n',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              children: [
                TextSpan(
                  text: '$quotePriceStr ${_data["quoteSymbol"]}',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  text: 'Exchange volume\n',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '${double.parse(_data["percentExchangeVolume"]).toStringAsFixed(4)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text.rich(
                TextSpan(
                  text: '24H USD volume\n',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '\$${double.parse(_data["volumeUsd24Hr"]).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ],
      ),
    );
  }
}
