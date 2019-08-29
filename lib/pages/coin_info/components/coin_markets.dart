import 'package:crypto_watcher/providers/coins.dart';
import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:crypto_watcher/utils.dart';
import 'package:flutter/material.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';

class CoinMarkets extends StatefulWidget {
  final String _coinId;
  final String _coinSymbol;
  final Function _onChanged;

  CoinMarkets(
    this._coinSymbol,
    this._coinId, {
    Key key,
    @required Function onChanged,
  })  : _onChanged = onChanged,
        super(key: key);

  @override
  _CoinMarketsState createState() => _CoinMarketsState();
}

class _CoinMarketsState extends State<CoinMarkets> {
  String _selectedExchange;
  Map _selectedCoinPair;

  Future _coinMarkets;

  final Map exchanges = Map<String, Map>();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  _loadData() {
    _coinMarkets = CoincapApi.markets(baseId: widget._coinId).then((response) {
      response["data"].forEach((exchange) {
        final exchangeId = exchange["exchangeId"];

        if (!exchanges.containsKey(exchangeId)) {
          exchanges[exchangeId] = {};
        }
        exchanges[exchangeId][exchange["quoteId"]] = exchange;
      });
      setState(() {
        _selectedExchange = exchanges.keys.first;
        _selectedCoinPair = exchanges[_selectedExchange].values.first;
      });
      widget._onChanged(_selectedCoinPair);
      return exchanges;
    });
  }

  @override
  Widget build(BuildContext context) {
    final coinsProvider = Provider.of<Coins>(context);

    return FutureBuilder(
      future: _coinMarkets,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        final exchangeName = coinsProvider.exchanges[_selectedExchange]["name"];
        final coinPairSymbol = _selectedCoinPair["quoteSymbol"];

        return GestureDetector(
          onTap: () {
            _showMarketsDialog(context, coinsProvider);
          },
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  margin:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 60.0),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    border: Border(
                      bottom:
                          BorderSide(color: AppColors.backgroundLight, width: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          '$exchangeName',
                          style: TextStyle(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${widget._coinSymbol}/$coinPairSymbol',
                          style: TextStyle(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _showMarketsDialog(BuildContext context, Coins coinsProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: Color(0xff222530),
          child: Container(
            height: screenSize.height,
            width: screenSize.width,
            child: CustomScrollView(
              slivers: [
                ...exchanges.keys
                    .map<Widget>(
                      (exchangeId) => _buildSliverList(
                        exchangeId,
                        coinsProvider,
                      ),
                    )
                    .toList()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverList(String exchangeId, Coins coinsProvider) {
    return SliverStickyHeader(
      header: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        color: AppColors.backgroundColor,
        child: Text(
          coinsProvider.exchanges[exchangeId]["name"],
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      sliver: SliverFixedExtentList(
        itemExtent: 60,
        delegate: SliverChildListDelegate(
          ListTile.divideTiles(
            color: AppColors.backgroundLight,
            tiles: exchanges[exchangeId].values.map<Widget>(
              (coinPair) {
                final quoteSymbol = coinPair["quoteSymbol"];
                final quotePriceStr = formatQuotePrice(coinPair["priceQuote"]);

                return ListTile(
                  onTap: () {
                    setState(() {
                      _selectedExchange = exchangeId;
                      _selectedCoinPair = coinPair;
                    });
                    widget._onChanged(_selectedCoinPair);

                    Navigator.of(context).pop();
                  },
                  title: Text(
                    '${widget._coinSymbol}/$quoteSymbol',
                    style: TextStyle(color: AppColors.secondaryDark),
                  ),
                  subtitle: Text(
                    '$quotePriceStr $quoteSymbol',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ).toList(),
          ).toList(),
        ),
      ),
    );
  }
}
