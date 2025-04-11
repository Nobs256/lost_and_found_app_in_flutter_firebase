import 'package:flutter/material.dart';

import '../src/app_color.dart';

class SubmitButtonDecoration extends StatelessWidget {
  final Widget child;

  const SubmitButtonDecoration({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AppColor.defaultColor,
      ),
      child: child,
    );
  }
}
