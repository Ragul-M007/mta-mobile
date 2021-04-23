import 'package:flutter/material.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';

class Comments extends StatefulWidget {
  static const String routeName = "/comments";

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: appbar("Comments"),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Image.asset("assets/icons/doc.png",
                          width: 15.0, height: 15.0),
                      Text("MTA Construction")
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Image.asset("assets/icons/Comments.png",
                          width: 15.0, height: 15.0),
                      SizedBox(width: 10),
                      Text("43 Comments")
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(),
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemBuilder: (BuildContext ctx, int index) {
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: new BoxDecoration(
                                    color: const Color(0xff7c94b6),
                                    image: new DecorationImage(
                                      image: new AssetImage(
                                          "assets/icons/p3.jpeg"),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(50.0)),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Rajesh Kumar . 2hrs ago"),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Container(
                                      child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "hihsdfi kjshdfiu  isuhfd ushhdifsiudhf khsidfh shbfihvbisnviusn shbih ishvnisud ihsbdvhis ihsbdvhs hsbdvh  hsbvh uh shbv jjsbvb ",
                                                  style: Drawables
                                                      .adddoccontentstyle(
                                                          Colors.black45,
                                                          14.0,
                                                          FontWeight.w400)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, '/replies');
                                                },
                                                child: Text(
                                                  "4 Replies",
                                                  style: TextStyle(
                                                      color: Color(0xFF0061b0)),
                                                ),
                                              )
                                            ],
                                          )),
                                      width: MediaQuery.of(context).size.width *
                                          0.75,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadiusDirectional.circular(
                                                  10)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            MySeparator(
                              color: Colors.grey[300],
                            )
                          ],
                        ));
                  })),
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    color: Colors.white),
                child: TextField(
                  // controller: _msgcontroller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: "Type your comment..",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.send, color: Color(0xFF0061b0))),
                ),
              ),
            ),
          ),
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
