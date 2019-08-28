import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/pages/coin_info/components/coin_markets.dart';
import 'package:crypto_watcher/providers/alerts.dart';
import 'package:crypto_watcher/providers/coins.dart';
import 'package:crypto_watcher/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;

class AlertsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, alertsProvider, _) {
        if (alertsProvider.status == Status.Loading) {
          return Center(child: LoadingIndicator());
        }
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          floatingActionButton: FloatingActionButton(
            tooltip: "Add an alert to this coin",
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return MultiProvider(
                      providers: [
                        Provider.value(value: alertsProvider),
                        Provider.value(value: Provider.of<Coins>(context)),
                      ],
                      child: AddAlertDialog(),
                    );
                  });
            },
            child: Icon(Icons.add),
            backgroundColor: AppColors.secondaryDark,
          ),
          body: ListView(
            children: alertsProvider.alerts.map<Widget>((alert) {
              return ListTile(
                title: Text(alert["price"].toString()),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class AddAlertDialog extends StatefulWidget {
  @override
  _AddAlertDialogState createState() => _AddAlertDialogState();
}

enum AlertType { PriceAbove, PriceBelow, PriceChangeBy }

class _AddAlertDialogState extends State<AddAlertDialog> {
  var _alertType = AlertType.PriceAbove;
  var _inputController = TextEditingController();
  bool _validInput = true;
  Map _pairData;
  int _checkInterval = 5;

  @override
  Widget build(BuildContext context) {
    final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,
      title: Text("Create an alert",
          style: TextStyle(color: Colors.white, fontSize: 15)),
      content: Container(
        height: 230,
        width: 9999,
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: AppColors.backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Center(
                  child: CoinMarkets(
                    alertsProvider.coinSymbol,
                    alertsProvider.coinId,
                    onChanged: (exchangeId, pairId, pairData) {
                      setState(() {
                        _pairData = pairData;
                        _inputController.text =
                            formatQuotePrice(pairData["priceQuote"]);
                      });
                    },
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text("Alert me when price "),
                    SizedBox(width: 5),
                    DropdownButton(
                      value: _alertType,
                      onChanged: (value) {
                        setState(() {
                          _alertType = value;
                          _inputController.text =
                              _alertType == AlertType.PriceChangeBy
                                  ? "5"
                                  : formatQuotePrice(_pairData["priceQuote"]);
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: AlertType.PriceAbove,
                          child: Text(
                            "is above",
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AlertType.PriceBelow,
                          child: Text(
                            "is below",
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AlertType.PriceChangeBy,
                          child: Text(
                            "changes by",
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                _buildInputs(),
                Row(
                  children: <Widget>[
                    Text("Check every "),
                    SizedBox(width: 5),
                    DropdownButton(
                      value: _checkInterval,
                      onChanged: (value) {
                        setState(() {
                          _checkInterval = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 5,
                          child: Text(
                            "5 minutes",
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 15,
                          child: Text(
                            "15 minutes",
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 30,
                          child: Text(
                            "30 minutes",
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 60,
                          child: Text(
                            "1 hour",
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Center(
                  child: OutlineButton(
                    onPressed: () {},
                    child: Text(
                      "Save",
                      style: TextStyle(color: AppColors.secondaryDark),
                    ),
                    borderSide: BorderSide(color: AppColors.secondaryDark),
                    shape: StadiumBorder(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputs() {
    if (_pairData == null) {
      return Container();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: _inputController,
            style: TextStyle(color: Colors.white),
            cursorColor: AppColors.secondaryDark,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            onChanged: _validateInput,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(bottom: 1),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.secondaryDark,
                  width: 0.7,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _validInput ? AppColors.secondaryColor : Colors.red,
                  width: 0.7,
                ),
              ),
            ),
          ),
        ),
        Text(
          _alertType == AlertType.PriceChangeBy ? "%" : _pairData["quoteSymbol"],
          style: TextStyle(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  _validateInput(String value) {
    final rx = RegExp(r"(^\d*\.?\d*[1-9]+\d*$)|(^[1-9]+\d*\.\d*$)");
    setState(() {
      _validInput = rx.hasMatch(value);
    });
  }
}
