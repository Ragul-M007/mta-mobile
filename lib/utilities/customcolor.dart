import 'package:flutter/material.dart';

mixin CustomColors {
  static final Color appthemecolor = Color(0xFF8686f1);
  //  Color(0xFF6bc772);
  static final primarycolor = Color(0xFF0061b0);

  static final Gradient gradientappColor = LinearGradient(colors: <Color>[
    Color(0xFF8686f1),
    Color(0xFFa37af4),
  ]);

  static final Color fontColor = Color.fromARGB(255, 110, 112, 113);

  static final Gradient gradientappthemecolor = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [
        0.3,
        1
      ],
      colors: <Color>[
        Color(0xFF8686f1),
        Color(0xFFa37af4),
      ]);
}
