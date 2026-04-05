import 'package:flutter/material.dart';

SnackBar goldSnackBar(String msg) => SnackBar(
      content: Text(
        msg,
        style: const TextStyle(
          color: Color(0xFFf0d080),
          fontSize: 13,
        ),
      ),
      backgroundColor: const Color(0xFF13131f),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF2a2a3e)),
      ),
    );