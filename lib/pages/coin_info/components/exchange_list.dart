import 'package:crypto_watcher/providers/coins.dart';
import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:flutter/material.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;
import 'package:provider/provider.dart';

class ExchangeList extends StatefulWidget {
  final String _coinId;
  final String _coinSymbol;
  final Function _onExchangeChanged;
  final Function _onCoinPairChanged;

  ExchangeList(
    this._coinSymbol,
    this._coinId, {
    Key key,
    @required Function onExchangeChanged,
    @required Function onCoinPairChanged,
  })  : _onExchangeChanged = onExchangeChanged,
        _onCoinPairChanged = onCoinPairChanged,
        super(key: key);

  @override
  _ExchangeListState createState() => _ExchangeListState();
}

class _ExchangeListState extends State<ExchangeList> {
  String _selectedExchange;
  String _selectedCoinPair;

  Future _exchangesRequest;
  final Map exchanges = Map<String, Map>();

  @override
  void initState() {
    _exchangesRequest = CoincapApi.markets(baseId: widget._coinId).then((response) {
      List data = response["data"];
      data.forEach((exchange) {
        final exchangeId = exchange["exchangeId"];

        if (!exchanges.containsKey(exchangeId)) {
          exchanges[exchangeId] = {};
        }
        exchanges[exchangeId][exchange["quoteId"]] = exchange;
      });
      setState(() {
        _selectedExchange = exchanges.keys.first;
        _selectedCoinPair = exchanges[_selectedExchange].keys.first;
      });
      widget._onExchangeChanged(_selectedExchange);
      widget._onCoinPairChanged(
          _selectedCoinPair, exchanges[_selectedExchange][_selectedCoinPair]);

      return exchanges;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final coinsProvider = Provider.of<Coins>(context);

    return FutureBuilder(
      future: _exchangesRequest,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        Map data = snapshot.data;

        return Theme(
          data: Theme.of(context).copyWith(canvasColor: AppColors.backgroundColor),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButton(
                  value: _selectedExchange,
                  underline: Divider(color: AppColors.backgroundLight),
                  onChanged: (val) {
                    setState(() {
                      _selectedExchange = val;
                      _selectedCoinPair = data[_selectedExchange].keys.first;
                    });

                    widget._onExchangeChanged(val);
                    widget._onCoinPairChanged(_selectedCoinPair,
                        exchanges[_selectedExchange][_selectedCoinPair]);
                  },
                  items: data.keys.map((exchangeId) {
                    return DropdownMenuItem(
                      child: Text(
                        coinsProvider.exchanges[exchangeId]["name"],
                        style: TextStyle(color: AppColors.secondaryDark),
                      ),
                      value: exchangeId,
                    );
                  }).toList(),
                ),
                _selectedExchange != null
                    ? DropdownButton(
                        value: _selectedCoinPair,
                        underline: Divider(color: AppColors.backgroundLight),
                        onChanged: (val) {
                          if (val == _selectedCoinPair) {
                            return;
                          }

                          setState(() {
                            _selectedCoinPair = val;
                          });
                          widget._onCoinPairChanged(
                              val, exchanges[_selectedExchange][_selectedCoinPair]);
                        },
                        items: data[_selectedExchange]
                            .values
                            .map<DropdownMenuItem<String>>((pairData) {
                          return DropdownMenuItem<String>(
                            child: Text(
                              '${widget._coinSymbol}/${pairData["quoteSymbol"]}',
                              style: TextStyle(color: AppColors.secondaryDark),
                            ),
                            value: pairData["quoteId"],
                          );
                        }).toList(),
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}
