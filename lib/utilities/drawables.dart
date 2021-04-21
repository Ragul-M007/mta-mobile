import 'package:flutter/material.dart';
import 'package:mta/utilities/customcolor.dart';

mixin Drawables {
  static final lbtnshape = new RoundedRectangleBorder(
    borderRadius: new BorderRadius.circular(10.0),
  );

  static final lloginbtn = BoxDecoration(
      borderRadius: new BorderRadius.circular(10.0),
      // color: CustomColors.appthemecolor,
      gradient: CustomColors.gradientappthemecolor);

  static final cancelshape = new RoundedRectangleBorder(
    borderRadius: new BorderRadius.circular(10.0),
  );

  static final cancelbtn = BoxDecoration(
    borderRadius: new BorderRadius.circular(10.0),
    color: Colors.white,
  );

  static final bgOrangeGradient = Container(
    decoration: BoxDecoration(
      color: CustomColors.appthemecolor,
    ),
  );

  static final aboxTopRadius = BoxDecoration(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(50.0),
      topRight: Radius.circular(50.0),
    ),
    color: Colors.white,
  );

  static final lTextStyle = TextStyle(
    color: CustomColors.appthemecolor,
    fontSize: 14.0,
  );

  static InputDecoration lInputDecoration(String arg) {
    var _input;
    var _helperText;
    _input = arg;
    return InputDecoration(
        border: UnderlineInputBorder(),
        focusColor: CustomColors.appthemecolor,
        labelText: _input,
        helperText: _helperText,
        labelStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        helperStyle: TextStyle(
          color: Colors.grey,
        ));
  }

  static BoxDecoration menudecorationImage(String img, double circleradius) {
    return new BoxDecoration(
      // color: const Color(0xff7c94b6),
      image: new DecorationImage(
        image: new AssetImage(img),
        fit: BoxFit.fill,
      ),
      borderRadius: new BorderRadius.all(new Radius.circular(circleradius)),
    );
  }

  // add document screen style here

  static TextStyle adddoccontentstyle(
      Color color, double size, FontWeight weight) {
    return TextStyle(color: color, fontSize: size, fontWeight: weight);
  }
}
