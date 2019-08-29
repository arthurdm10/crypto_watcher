import 'package:crypto_watcher/pages/coin_info/components/candle_chart.dart';
import 'package:crypto_watcher/pages/coin_info/components/coin_markets.dart';
import 'package:crypto_watcher/pages/coin_info/components/intervals_list.dart';
import 'package:crypto_watcher/pages/coin_info/components/pair_data.dart';
import 'package:crypto_watcher/pages/coin_info/pages/alerts.dart';
import 'package:crypto_watcher/providers/alert_provider.dart';
import 'package:crypto_watcher/providers/coins.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoinInfo extends StatefulWidget {
  final String _coinId;
  final String _coinSymbol;
  final String _coinName;

  CoinInfo(this._coinId, this._coinSymbol, this._coinName);

  @override
  _CoinInfoState createState() => _CoinInfoState();
}

class _CoinInfoState extends State<CoinInfo> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget._coinName),
        backgroundColor: AppColors.backgroundColor,
        leading: SizedBox(
          width: 20,
          height: 20,
          child: Image.asset('assets/icons/${widget._coinSymbol.toLowerCase()}.png'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondaryDark,
          tabs: <Widget>[
            Tab(text: "Chart"),
            Tab(text: "Alerts"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CoinChart(widget._coinId, widget._coinSymbol, widget._coinName),
          MultiProvider(
            providers: [
              Provider.value(value: Provider.of<Coins>(context)),
              Provider.value(value: Provider.of<AlertsProvider>(context)),
            ],
            child: AlertsPage(widget._coinId, widget._coinSymbol),
          )
        ],
      ),
    );
  }
}

class CoinChart extends StatefulWidget {
  final String _coinId;
  final String _coinSymbol;
  final String _coinName;

  CoinChart(this._coinId, this._coinSymbol, this._coinName);

  @override
  _CoinChartState createState() => _CoinChartState();
}

class _CoinChartState extends State<CoinChart>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<CoinChart> {
  ChartInterval _interval = ChartInterval.m15;
  String _selectedExchange;
  String _selectedCoinPair;
  Map<String, dynamic> _pairData;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CoinMarkets(
                widget._coinSymbol,
                widget._coinId,
                onChanged: _onCoinPairChanged,
              ),
              SizedBox(height: 5),
              PairData(_pairData),
              SizedBox(height: 15),
              ChartIntervalList(
                onSelected: _onChartIntervalChanged,
              ),
              SizedBox(height: 15),
              CandleChart(
                exchangeId: _selectedExchange,
                coinId: widget._coinId,
                coinPairId: _selectedCoinPair,
                interval: _interval,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onChartIntervalChanged(interval) {
    setState(() {
      _interval = interval;
    });
  }

  _onCoinPairChanged(data) {
    setState(() {
      _selectedExchange = data["exchangeId"];
      _selectedCoinPair = data["quoteId"];
      _pairData = data;
    });
  }
}
