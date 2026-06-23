import 'package:flutter/material.dart';
import 'package:mta/utilities/customcolor.dart';

// ignore: must_be_immutable
class ThemeButton extends StatelessWidget {
  final String title;

  double? height, width;

  final VoidCallback? buttonfunction;

  ThemeButton({super.key, required this.title, required this.buttonfunction});

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height! * .052,
      width: width!,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: CustomColors.primarycolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          onPressed: buttonfunction,
          child: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
    );
  }
}
