import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/pages/home.dart';
import 'package:crypto_watcher/providers/alert_provider.dart';
import 'package:crypto_watcher/providers/coins.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coins = Coins();

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
          final alerts = AlertsProvider();
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: coins),
              Provider.value(value: alerts),
            ],
            child: HomePage(),
          );
        },
      ),
    );
  }
}

Container buildGraph(List<Color> gradientColors) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      color: AppColors.backgroundColor,
    ),
    child: FlChart(
      chart: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 12,
              textStyle: TextStyle(
                  color: const Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              getTitles: (value) {
                switch (value.toInt()) {
                  case 2:
                    return 'MAR';
                  case 5:
                    return 'JUN';
                  case 8:
                    return 'SEP';
                }

                return '';
              },
              margin: 8,
            ),
            leftTitles: SideTitles(
              showTitles: true,
              textStyle: TextStyle(
                color: const Color(0xff677ffd),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              getTitles: (value) {
                final intVal = value.toInt();
                return intVal % 2 == 0 && intVal > 0 ? '${intVal}k' : '';
              },
              reservedSize: 28,
              margin: 12,
            ),
          ),
          borderData: FlBorderData(
            show: false,
            border: Border.all(color: Color(0xff37434d), width: 2),
          ),
          minX: 0,
          maxX: 12,
          minY: 0,
          maxY: 10,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 2.5),
                FlSpot(2.6, 2),
                FlSpot(4.9, 5),
                FlSpot(6.8, 3.1),
                FlSpot(8, 4),
                FlSpot(9.5, 3),
                FlSpot(11, 4),
              ],
              isCurved: true,
              colors: gradientColors,
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
              ),
              belowBarData: BelowBarData(
                show: true,
                colors:
                    gradientColors.map((color) => color.withOpacity(0.1)).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
