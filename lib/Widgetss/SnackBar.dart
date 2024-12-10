import 'package:flutter/material.dart';

class SnackBarUtil {
  static bool isSnackBarVisible = false;

  static void showSnackBar(BuildContext context, String message) {
    if (isSnackBarVisible) return;
    isSnackBarVisible = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        onVisible: () {
          Future.delayed(const Duration(seconds: 2), () {
            isSnackBarVisible = false;
          });
        },
      ),
    );
  }
}