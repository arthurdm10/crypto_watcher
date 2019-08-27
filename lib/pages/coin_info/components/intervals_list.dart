import 'package:flutter/material.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;

enum ChartInterval { m5, m15, m30, h1, h2, h12, d1 }

class ChartIntervalList extends StatefulWidget {
  static const Map _intervalText = {
    ChartInterval.m5: "5 MIN",
    ChartInterval.m15: "15 MIN",
    ChartInterval.m30: "30 MIN",
    ChartInterval.h1: "1 H",
    ChartInterval.h2: "2 H",
    ChartInterval.h12: "12 H",
    ChartInterval.d1: "1 D"
  };

  final Function onSelected;

  ChartIntervalList({Key key, @required this.onSelected}) : super(key: key);

  @override
  _ChartIntervalListState createState() => _ChartIntervalListState();
}

class _ChartIntervalListState extends State<ChartIntervalList> {
  ChartInterval _selected = ChartInterval.h1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: ChartInterval.values.map((interval) {
          final color = interval == _selected
              ? AppColors.secondaryDark
              : AppColors.backgroundLight;
          return GestureDetector(
            onTap: () {
              widget.onSelected(interval);
              setState(() {
                _selected = interval;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: color,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  ChartIntervalList._intervalText[interval],
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
