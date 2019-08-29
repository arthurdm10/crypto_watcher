import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/pages/home.dart';
import 'package:crypto_watcher/providers/alert_provider.dart';
import 'package:crypto_watcher/providers/coins_provider.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coins = CoinsProvider();

    return MaterialApp(
      theme: ThemeData(
        backgroundColor: AppColors.backgroundColor,
      ),
      title: 'Crypto Watcher',
      home: FutureBuilder(
        future: coins.loadDb(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load local database",
                style: TextStyle(
                  color: AppColors.secondaryDark,
                  fontSize: 18,
                ),
              ),
            );
          }

          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: coins),
              Provider.value(value: AlertsProvider()),
            ],
            child: HomePage(),
          );
        },
      ),
    );
  }
}
