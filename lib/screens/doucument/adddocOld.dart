import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AddDoc extends StatefulWidget {
  static const String routeName = "/adddoc";

  @override
  _AddDocState createState() => _AddDocState();
}

class _AddDocState extends State<AddDoc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Add Doc"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text("Document Title"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 50,
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
              child: Text("Text",textAlign: TextAlign.start,),
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            
            ),
            ),
          ), Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text("Description"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 200,
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
              child: Text("Text",textAlign: TextAlign.start,),
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            
            ),
            ),
          ),
          SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Text("upload file"),
              SizedBox(width: 20,),
              ButtonTheme(
                            // minWidth: double.infinity,
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                textColor: Colors.white,
                                // padding: EdgeInsets.all(15),
                                onPressed: () {
                               
                                },
                                child: Text(
                                  "Upload",
                                ),
                                color: Colors.red),
                          )
            ],),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
                              minWidth: double.infinity,
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  textColor: Colors.white,
                                  // padding: EdgeInsets.all(15),
                                  onPressed: () {
                                 
                                  },
                                  child: Text(
                                    "Submit",
                                  ),
                                  color: Colors.blue),
                            ),
          )
         
        ],
      ),
    );
  }
}

