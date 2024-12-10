import 'package:flutter/material.dart';

Widget bottomNavigationBar({
  required VoidCallback onPressed,
  required String label,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xff45BBCF)),
        textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(fontSize: 16)),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(16)),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: Colors.white,
        ),
      ),
    ),
  );
}

