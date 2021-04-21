import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Categories extends StatefulWidget {
  static const String routeName = "/categories";

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Project Details"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  child: Icon(Icons.ac_unit),
                  backgroundColor: Colors.red,
                  radius: 25,
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Laxmi mills, Coimbatore"),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.info_outlined,
                          size: 15,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.pin_drop),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Laxmi mills, Coimbatore")
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemBuilder: (BuildContext ctx, int index) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 70,
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Wooden Works",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                            )
                          ],
                        )),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                  ),
                );
                // return Text("hi");
              },
              itemCount: 5,
            ),
          )
        ],
      ),
    );
  }
}
