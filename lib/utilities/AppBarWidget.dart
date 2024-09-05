// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
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
        leading: IconButton(padding: EdgeInsets.only(left: 15),
                    onPressed: backButtonfunction,
                    icon: Icon(
                      (!kIsWeb && Platform.isIOS)
                          ? Icons.arrow_back_ios
                          : Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
        actions: actionWidget,
      ),
    );
  }
}
