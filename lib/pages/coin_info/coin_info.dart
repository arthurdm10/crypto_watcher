import 'package:crypto_watcher/pages/coin_info/components/candle_chart.dart';
import 'package:crypto_watcher/pages/coin_info/components/exchange_list.dart';
import 'package:crypto_watcher/pages/coin_info/components/intervals_list.dart';
import 'package:crypto_watcher/pages/coin_info/components/pair_data.dart';
import 'package:crypto_watcher/pages/coin_info/pages/alerts.dart';
import 'package:crypto_watcher/providers/alerts.dart';
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
  ChartInterval _interval = ChartInterval.m15;
  String _selectedExchange;
  String _selectedCoinPair;
  Map<String, dynamic> _pairData;
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
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: PairData(_pairData)),
                      ExchangeList(
                        widget._coinSymbol,
                        widget._coinId,
                        onExchangeChanged: (exchangeId) {
                          setState(() {
                            _selectedExchange = exchangeId;
                          });
                        },
                        onCoinPairChanged: (pairId, data) {
                          setState(() {
                            _selectedCoinPair = pairId;
                            _pairData = data;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  ChartIntervalList(
                    onSelected: (interval) {
                      setState(() {
                        _interval = interval;
                      });
                    },
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
          ChangeNotifierProvider(
            builder: (_) => AlertsProvider(widget._coinId),
            child: AlertsPage(),
          ),
        ],
      ),
    );
  }
}
