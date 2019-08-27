import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/providers/alerts.dart';
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
                    return Provider.value(
                      value: alertsProvider,
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

class AddAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,
      title: Text("Add a alert"),
    );
  }
}
