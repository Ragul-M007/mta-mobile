import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Comments extends StatefulWidget {
  static const String routeName = "/comments";

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  IO.Socket _socket;
  var _currDoc;

  TextEditingController _msgcontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    print("in");

    if (Strings.category == true) {
      _currDoc = Strings.selectedCatDocument[0];
    } else {
      _currDoc = Strings.selectedProDocument[0];
    }
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': Strings.authToken, "document_id": _currDoc.documentId}
    });
    _socket.connect();
    _socket.on("connect", (_) {
      print('Connected');
      getComments();
    });

    // _socket.on("create-document-comment", (data) {
    //   print("messages" + data);
    // });
    // _socket.on("connect_error", (data) => print('connect_error:  $data'));
    // _socket.on("connect_timeout", (data) => print('connect_timeout:  $data'));
    // _socket.on("connecting", (data) => print('connecting:  $data'));
    // _socket.on("error", (data) => print('error:  $data'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
                      Image.asset(
                          getFileExt(Strings.category == true
                              ? Strings.selectedCatDocument[0].fileName
                              : Strings.selectedProDocument[0].fileName),
                          width: 30.0,
                          height: 30.0),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          Strings.category == true
                              ? Strings.selectedCatDocument[0].fileName
                              : Strings.selectedProDocument[0].fileName,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Image.asset("assets/icons/Comments.png",
                          width: 15.0, height: 15.0),
                      SizedBox(width: 10),
                      Text(
                          Strings.category == true
                              ? Strings.selectedCatDocument[0].commentsCount
                                      .toString() +
                                  " Comments"
                              : Strings.selectedProDocument[0].commentsCount
                                      .toString() +
                                  " Comments",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600))
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(),
          Strings.comments.length > 0
              ? Expanded(
                  child: ListView.builder(
                      itemCount: Strings.comments.length,
                      padding: EdgeInsets.all(20),
                      itemBuilder: (BuildContext ctx, int index) {
                        return Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showMyDialog(
                                            context,
                                            Strings.baseImageUrl +
                                                Strings
                                                    .comments[index].userImg);
                                      },
                                      child: Container(
                                        width: 30.0,
                                        height: 30.0,
                                        decoration: new BoxDecoration(
                                          color: const Color(0xff7c94b6),
                                          image: new DecorationImage(
                                            image: new NetworkImage(
                                                Strings.baseImageUrl +
                                                    Strings.comments[index]
                                                        .userImg),
                                            fit: BoxFit.fill,
                                          ),
                                          borderRadius: new BorderRadius.all(
                                              new Radius.circular(50.0)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                                Strings.comments[index].name +
                                                    " . ",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            Container(
                                              width: 18.0,
                                              height: 18.0,
                                              child: IconButton(
                                                  padding:
                                                      new EdgeInsets.all(0.0),
                                                  color: Colors.grey,
                                                  icon: new Icon(Icons.update,
                                                      size: 18.0)),
                                            ),
                                            SizedBox(
                                              width: 1,
                                            ),
                                            Text(
                                                calculateTimeDifferenceBetween(
                                                    serverDate: Strings
                                                        .comments[index].date),
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontWeight:
                                                        FontWeight.w500))
                                          ],
                                        ),
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
                                                      Strings.comments[index]
                                                          .comment
                                                          .toString(),
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
                                                      Strings.selectedCommentsIndex =
                                                          index;
                                                      Navigator.pushNamed(
                                                          context, '/replies');
                                                    },
                                                    child: Text(
                                                      Strings.comments[index]
                                                              .replies.length
                                                              .toString() +
                                                          "  Replies",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF0061b0),
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  )
                                                ],
                                              )),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(10)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                MySeparator(
                                  color: Colors.grey[500],
                                )
                              ],
                            ));
                      }))
              : SizedBox(),
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
                  controller: _msgcontroller,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      hintText: "Type your comment..",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: Color(0xFF0061b0)),
                          onPressed: () {
                            postComments();
                          })),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getComments() {
    _socket.on("document-comments", (_data) {
      print('fromServer $_data');
      setState(() {
        Strings.comments = [];
        for (var item in _data) {
          Strings.comments.add(CommentsRes.fromJson(item));
        }
      });
    });
  }

  postComments() {
    //print(_msgcontroller.text);
    _socket.emit(
        'create-document-comment',
        json.encode({
          "comment": _msgcontroller.text,
          "document_id": Strings.category == true
              ? Strings.selectedCatDocument[0].documentId
              : Strings.selectedProDocument[0].documentId,
          'recipient_id': null,
          'recipient': ""
        }));
    setState(() {
      if (Strings.category == true) {
        Strings.selectedCatDocument[0].commentsCount =
            Strings.selectedCatDocument[0].commentsCount + 1;
      } else {
        Strings.selectedProDocument[0].commentsCount =
            Strings.selectedProDocument[0].commentsCount + 1;
      }
      _msgcontroller.text = '';
    });
  }

  String getFileExt(String fileName) {
    var file = fileName.split(".");
    var fileExt = file[1];
    if (fileExt == "png" || fileExt == "PNG") {
      return "assets/icons/png.png";
    } else if (fileExt == "jpg" ||
        fileExt == "jepg" ||
        fileExt == "jpeg" ||
        fileExt == "JPG" ||
        fileExt == "JEPG" ||
        fileExt == "JPEG") {
      return "assets/icons/jpg.png";
    } else if (fileExt == "pdf" || fileExt == "PDF") {
      return "assets/icons/pdf.png";
    } else if (fileExt == "txt" || fileExt == "TXT") {
      return "assets/icons/txt.png";
    } else if (fileExt == "ppt" || fileExt == "PPT") {
      return "assets/icons/ppt.png";
    } else if (fileExt == "xls" ||
        fileExt == "xlsx" ||
        fileExt == "xlsm" ||
        fileExt == "xlsb" ||
        fileExt == "xltx") {
      return "assets/icons/xls.png";
    } else {
      return "assets/icons/doc.png";
    }
  }

  static String calculateTimeDifferenceBetween({@required String serverDate}) {
    DateTime startDate = DateTime.parse(serverDate);
    DateTime endDate = DateTime.now();
    int seconds = endDate.difference(startDate).inSeconds;
    if (seconds < 60)
      return '${seconds.abs()} second ago';
    else if (seconds >= 60 && seconds < 3600)
      return '${startDate.difference(endDate).inMinutes.abs()} minute ago';
    else if (seconds >= 3600 && seconds < 86400)
      return '${startDate.difference(endDate).inHours.abs()} hour ago';
    else
      return '${startDate.difference(endDate).inDays.abs()} day ago';
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

Future<void> _showMyDialog(context, imgurl) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    new Icon(Icons.close, size: 22.0, color: Colors.black),
                  ],
                ),
                decoration: new BoxDecoration(
                  color: Colors.transparent,
                  image: new DecorationImage(
                    image: new NetworkImage(imgurl),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
                ),
              )),
        ),
      );
    },
  );
}
