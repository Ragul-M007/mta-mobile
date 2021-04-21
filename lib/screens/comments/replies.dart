import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Replies extends StatefulWidget {
  static const String routeName = "/replies";

  @override
  _RepliesState createState() => _RepliesState();
}

class _RepliesState extends State<Replies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Replies"),
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
         Padding(padding:EdgeInsets.symmetric(vertical: 10) ,child:Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    CircleAvatar(backgroundColor: Colors.red,child: Icon(Icons.ac_unit_outlined),),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Rajesh Kumar . 2hrs ago"),
                      SizedBox(height: 12,),
                      Container(child:
                      Padding(padding: EdgeInsets.all(10),child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text("hihsdfi kjshdfiu  isuhfd ushhdifsiudhf khsidfh shbfihvbisnviusn shbih ishvnisud ihsbdvhis ihsbdvhs hsbdvh  hsbvh uh shbv jjsbvb ",
                       overflow: TextOverflow.clip,
                       ),
                       SizedBox(height: 10,),
                       
                      ],)),
                       width: MediaQuery.of(context).size.width *0.75,
                       decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadiusDirectional.circular(10)),
                       ),
                       SizedBox(height: 10,),
                       Row(children: [
                         Icon(Icons.ios_share),
                         SizedBox(width: 10,),
                         Text("4 Replies",style: TextStyle(color:Colors.blue ),),
                       ],)
                    ],)
                    ,
                  ],),
                ),
                SizedBox(height: 20,),
                MySeparator(color: Colors.grey[300],)
              ],
            )),
          Expanded(child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemBuilder: (BuildContext ctx,int index){
            return Padding(padding:EdgeInsets.symmetric(vertical: 10) ,child:Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  CircleAvatar(backgroundColor: Colors.red,child: Icon(Icons.ac_unit_outlined),),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Rajesh Kumar . 2hrs ago"),
                    Container(child:
                    Padding(padding: EdgeInsets.all(10),child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("hihsdfi kjshdfiu  isuhfd ushhdifsiudhf khsidfh shbfihvbisnviusn shbih ishvnisud ihsbdvhis ihsbdvhs hsbdvh  hsbvh uh shbv jjsbvb ",
                     overflow: TextOverflow.clip,
                     ),
                     SizedBox(height: 10,),
                    ],)),
                     width: MediaQuery.of(context).size.width *0.75,
                     decoration: BoxDecoration(color: Colors.transparent,borderRadius: BorderRadiusDirectional.circular(10)),
                     ),
                  ],)
                  ,
                ],),
                SizedBox(height: 20,),
                MySeparator(color: Colors.grey[300],)
              ],
            ));
          })),
        Container( 
          width: double.infinity,
      child:  Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
                      padding: EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white
                      ),
                      child: TextField(
                        // controller: _msgcontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Type your comment..",
                            hintStyle: TextStyle(color: Colors.black),
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.send)
                            ),
                      ),
                    ),
        ),),
   
        ],
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}