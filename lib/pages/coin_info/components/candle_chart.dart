import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/pages/coin_info/components/intervals_list.dart';
import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:crypto_watcher/styles/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';
import 'dart:math' as math;

class CandleChart extends StatefulWidget {
  final ChartInterval _interval;
  final String exchangeId;
  final String coinPairId;

  const CandleChart({
    Key key,
    @required this.exchangeId,
    @required this.coinPairId,
    @required String coinId,
    @required ChartInterval interval,
  })  : _coinId = coinId,
        _interval = interval,
        super(key: key);

  final String _coinId;

  @override
  _CandleChartState createState() => _CandleChartState();
}

class _CandleChartState extends State<CandleChart> {
  @override
  Widget build(BuildContext context) {
    if (widget._coinId == null || widget.coinPairId == null) {
      return Center(child: LoadingIndicator());
    }
    Duration candleStart;
    final interval = widget._interval;
    switch (interval) {
      case ChartInterval.m5:
        candleStart = Duration(hours: 6);
        break;
      case ChartInterval.m15:
        candleStart = Duration(hours: 24);
        break;
      case ChartInterval.m30:
        candleStart = Duration(hours: 48);
        break;
      case ChartInterval.h1:
      case ChartInterval.h2:
        candleStart = Duration(days: 5);
        break;
      case ChartInterval.h12:
        candleStart = Duration(days: 30);
        break;
      default:
        candleStart = Duration(days: 90);
        break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      height: 300,
      child: FutureBuilder(
        future: CoincapApi.candles(
            exchangeId: widget.exchangeId,
            baseId: widget._coinId,
            quoteId: widget.coinPairId,
            interval: describeEnum(widget._interval),
            start: DateTime.now()
                .subtract(
                  candleStart,
                )
                .millisecondsSinceEpoch,
            end: DateTime.now().millisecondsSinceEpoch),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingIndicator());
          }

          List data = snapshot.data["data"];

          if (data.isEmpty) {
            return Center(
              child: Text(
                "Couldn't get data",
                style: TextStyle(color: secondaryDark),
              ),
            );
          }

          double high = -1;
          double low = double.infinity;

          data.forEach((item) {
            item["open"] = double.parse(item["open"]);
            item["high"] = double.parse(item["high"]);
            item["low"] = double.parse(item["low"]);
            item["close"] = double.parse(item["close"]);
            item["volumeto"] = double.parse(item["volume"]);

            high = math.max(high, item["high"]);
            low = math.min(low, item["low"]);
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'High $high',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Low $low',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: OHLCVGraph(
                  data: data,
                  lineWidth: 0.7,
                  enableGridLines: true,
                  volumeProp: 0.1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
