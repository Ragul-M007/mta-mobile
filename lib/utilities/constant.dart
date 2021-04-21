import 'package:flutter/material.dart';
import 'package:mta/utilities/strings.dart';

Widget menuoption({
  @required Function ontab,
  @required selectedmenuvalue,
  @required String menutitle,
}) {
  return GestureDetector(
    onTap: ontab,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Strings.currentmenuvalue == selectedmenuvalue
            ? const Color(0XFF1c72b9)
            : const Color(0xFF0061b0),
      ),
      padding: EdgeInsets.fromLTRB(30, 4, 0, 4),
      child: Text(
        menutitle,
        style: TextStyle(
          fontSize: 17,
          color: Strings.currentmenuvalue == selectedmenuvalue
              ? Colors.white
              : const Color(0xFF519bd7),
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget button({@required Function ontab, @required String buttoncontent}) {
  return GestureDetector(
    onTap: ontab,
    child: Container(
      child: Center(
          child: Text(
        buttoncontent,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
        textAlign: TextAlign.center,
      )),
      width: double.infinity,
      height: 40,
      margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
      decoration: BoxDecoration(
          color: Color(0xFF0061b0), borderRadius: BorderRadius.circular(25)),
    ),
  );
}
