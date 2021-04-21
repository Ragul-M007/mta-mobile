import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text("category Info"),
      ),
      body: Padding(padding: EdgeInsets.all(20),child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SizedBox(height: 25,),
        Text("Wooden Works",style: TextStyle(color: Colors.blue),),  
        SizedBox(height: 10,),
        Container(
          child:Padding(padding: EdgeInsets.all(10),child: Text("hiiiiiiiiiiiiiiiiii",textAlign: TextAlign.start,),) ,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,borderRadius: BorderRadius.circular(5),

          ),)
        
        ],
      ),
    ));
  }
}
