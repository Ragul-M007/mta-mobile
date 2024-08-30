import 'package:flutter/material.dart';
import 'package:mta/utilities/drawables.dart';

class AppBarWidget extends StatelessWidget {
  String? title;
  final VoidCallback backButtonfunction;
  final List<Widget> actionWidget;
  AppBarWidget(
      {super.key,
      required this.backButtonfunction,
      required this.title,
      required this.actionWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.1, 1.0),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0)),
        ),
        elevation: 0,
        title: Text(
          title!,
          style:
              Drawables.adddoccontentstyle(Colors.black, 16.0, FontWeight.bold),
        ),
        leading: SizedBox(
          height: 25.0,
          width: 25.0,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 25.0,
              // color: const Color(0xFF979797),
            ),
            onPressed: backButtonfunction,
          ),
        ),
        actions: actionWidget,
      ),
    );
  }
}
