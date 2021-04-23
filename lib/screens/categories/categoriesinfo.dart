import 'package:flutter/material.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/drawables.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CategoriesInfo extends StatefulWidget {
  static const String routeName = "/categoriesinfo";

  @override
  _CategoriesInfoState createState() => _CategoriesInfoState();
}

class _CategoriesInfoState extends State<CategoriesInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: appbar("Category Info"),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 25,
              ),
              Text(
                "Wooden Works",
                style: Drawables.adddoccontentstyle(
                    CustomColors.primarycolor, 15.0, FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "hiiiiiiiiiiiiiiiiii",
                    textAlign: TextAlign.start,
                    style: Drawables.adddoccontentstyle(
                        Colors.grey, 12.0, FontWeight.normal),
                  ),
                ),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              )
            ],
          ),
        ));
  }
}
