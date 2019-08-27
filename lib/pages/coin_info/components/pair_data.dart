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

    return Container(
      margin: const EdgeInsets.only(left: 5, top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 5),
          Text(
            '\$${double.parse(_data["priceUsd"]).toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 5),
          Text.rich(
            TextSpan(
              text: '${_data["quoteSymbol"]} ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: double.parse(_data["priceQuote"]).toStringAsFixed(2),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Text.rich(
            TextSpan(
              text: 'Exchange volume: ',
              style: TextStyle(
                fontSize: 12,
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
          ),
          Text.rich(
            TextSpan(
              text: '24H USD volume: ',
              style: TextStyle(
                fontSize: 12,
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
          )
        ],
      ),
    );
  }
}
