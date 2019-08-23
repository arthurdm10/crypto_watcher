import 'package:crypto_watcher/styles/colors.dart' as AppColors;
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      strokeWidth: 2.5,
      backgroundColor: AppColors.backgroundColor,
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
    );
  }
}
