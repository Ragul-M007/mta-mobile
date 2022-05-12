import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:io' as Io;
//import 'package:audioplayers/audio_cache.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

List<FetchMapedUsersData> users = Strings.users;
List<CatsData> cats = Strings.categories;
AnimationController? _animationController;
AudioPlayer audioPlayer = AudioPlayer();
AudioCache audioCache = AudioCache();
final _userIitems = users
    .map((user) => MultiSelectItem<FetchMapedUsersData?>(user, user.name!))
    .toList();
final _catsItems = cats
    .map((cats) => MultiSelectItem<CatsData?>(cats, cats.categoryName!))
    .toList();
var tagedUsers = [];
var tagedUsersId = [];
var tagedCats = [];
var tagedCatsId = [];
var showscroll = true;
var typing = false;
var showtoastinfo = false;
var startRecording = false;

var isPlaying = false;
var playingIndex = null;
int audioLength = 0;
int audioCurrentlenth = 0;
Timer? _timer;
List<int> recordedData = [];
final _audioRecorder = Record();

class Replies extends StatefulWidget {
  static const String routeName = "/replies";

  @override
  _RepliesState createState() => _RepliesState();
}

class _RepliesState extends State<Replies> {
  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: Scaffold(
          appBar: appbar("Replies"),
          backgroundColor: Colors.grey[300],
          body: RepliesContent(),
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}

class RepliesContent extends StatefulWidget {
  static const String routeName = "/replies";

  @override
  _RepliesContentState createState() => _RepliesContentState();
}

class _RepliesContentState extends State<RepliesContent>
    with SingleTickerProviderStateMixin {
  IO.Socket? _socket;
  var _currDoc;

  TextEditingController _msgcontroller = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  FocusNode msgField = new FocusNode();
  @override
  void initState() {
    super.initState();
    Strings.pushNotify = false;
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    _animationController?.repeat(reverse: true);

    setState(() {
      tagedUsers = [];
      tagedUsersId = [];
      tagedCats = [];
      tagedCatsId = [];
      // Strings.comments = [];
    });

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
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      getReplies();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _socket?.disconnect();
    super.dispose();
    Strings.pushNotify = true;
    tagedUsers = [];
    tagedUsersId = [];
    tagedCats = [];
    tagedCatsId = [];
    // Strings.comments = [];
  }

  Stopwatch watch = Stopwatch();
  bool startStop = true;
  String elapsedTime = '';

  updateTime(Timer _timer) {
    if (watch.isRunning) {
      setState(() {
        print("startstop Inside=$startStop");
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showMyDialog(
                                context,
                                Strings.baseImageUrl +
                                    Strings
                                        .comments[Strings.selectedCommentsIndex]
                                        .userImg!);
                          },
                          child: Container(
                            width: 30.0,
                            height: 30.0,
                            decoration: new BoxDecoration(
                              color: const Color(0xff7c94b6),
                              image: new DecorationImage(
                                image: new NetworkImage(Strings.baseImageUrl +
                                    (Strings
                                            .comments[
                                                Strings.selectedCommentsIndex]
                                            .userImg ??
                                        "")),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    Strings
                                            .comments[
                                                Strings.selectedCommentsIndex]
                                            .name! +
                                        " . ",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                                Container(
                                  width: 18.0,
                                  height: 18.0,
                                  child: IconButton(
                                    padding: new EdgeInsets.all(0.0),
                                    color: Colors.grey,
                                    icon: new Icon(Icons.update, size: 18.0),
                                    onPressed: () {},
                                  ),
                                ),
                                SizedBox(
                                  width: 1,
                                ),
                                Text(
                                    calculateTimeDifferenceBetween(
                                        serverDate: Strings
                                            .comments[
                                                Strings.selectedCommentsIndex]
                                            .date!),
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500))
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
                                      Strings
                                                      .comments[Strings
                                                          .selectedCommentsIndex]
                                                      .audio ==
                                                  "" ||
                                              Strings
                                                      .comments[Strings
                                                          .selectedCommentsIndex]
                                                      .audio ==
                                                  null
                                          ? Text(
                                              Strings
                                                  .comments[Strings
                                                      .selectedCommentsIndex]
                                                  .comment
                                                  .toString(),
                                              style:
                                                  Drawables.adddoccontentstyle(
                                                      Colors.black45,
                                                      14.0,
                                                      FontWeight.w400))
                                          : Text("Audio Message",
                                              style:
                                                  Drawables.adddoccontentstyle(
                                                      Colors.black45,
                                                      14.0,
                                                      FontWeight.w400)),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  )),
                              width: MediaQuery.of(context).size.width * 0.75,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadiusDirectional.circular(10)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 15.0,
                                  height: 15.0,
                                  decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                      image: new AssetImage(
                                          "assets/icons/reply-message.png"),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(50.0)),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  Strings
                                          .comments[
                                              Strings.selectedCommentsIndex]
                                          .replies!
                                          .length
                                          .toString() +
                                      " Replies",
                                  style: TextStyle(
                                      color: Color(0xFF0061b0),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MySeparator(
                    color: Colors.grey[500]!,
                  )
                ],
              )),
          Strings.comments[Strings.selectedCommentsIndex].replies!.length > 0 &&
                  Strings.comments[Strings.selectedCommentsIndex].replies !=
                      null
              ? Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      controller: _scrollController,
                      padding: EdgeInsets.all(20),
                      itemCount: Strings.comments[Strings.selectedCommentsIndex]
                          .replies!.length,
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
                                                    .comments[Strings
                                                        .selectedCommentsIndex]
                                                    .replies![index]
                                                    .userImg!);
                                      },
                                      child: Container(
                                        width: 30.0,
                                        height: 30.0,
                                        decoration: new BoxDecoration(
                                          color: const Color(0xff7c94b6),
                                          image: new DecorationImage(
                                            image: new NetworkImage(Strings
                                                    .baseImageUrl +
                                                (Strings
                                                        .comments[Strings
                                                            .selectedCommentsIndex]
                                                        .replies![index]
                                                        .userImg ??
                                                    "")),
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
                                                Strings
                                                        .comments[Strings
                                                            .selectedCommentsIndex]
                                                        .replies![index]
                                                        .commentBy! +
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
                                                    size: 18.0),
                                                onPressed: () {},
                                              ),
                                            ),
                                            SizedBox(
                                              width: 1,
                                            ),
                                            Text(
                                                calculateTimeDifferenceBetween(
                                                    serverDate: Strings
                                                        .comments[Strings
                                                            .selectedCommentsIndex]
                                                        .replies![index]
                                                        .date!),
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontWeight:
                                                        FontWeight.w500))
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          child: Text(Strings
                                              .comments[
                                                  Strings.selectedCommentsIndex]
                                              .replies![index]
                                              .recipient!),
                                        ),
                                        Container(
                                          child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Strings
                                                                  .comments[Strings
                                                                      .selectedCommentsIndex]
                                                                  .replies![
                                                                      index]
                                                                  .audio ==
                                                              "" ||
                                                          Strings
                                                                  .comments[Strings
                                                                      .selectedCommentsIndex]
                                                                  .replies![
                                                                      index]
                                                                  .audio ==
                                                              null
                                                      ? Text(
                                                          Strings
                                                              .comments[Strings
                                                                  .selectedCommentsIndex]
                                                              .replies![index]
                                                              .comment
                                                              .toString(),
                                                          style: Drawables
                                                              .adddoccontentstyle(
                                                                  Colors
                                                                      .black45,
                                                                  14.0,
                                                                  FontWeight
                                                                      .w400))
                                                      : Row(
                                                          children: [
                                                            isPlaying == false
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (isPlaying ==
                                                                            true) {
                                                                          stopAudio();
                                                                          _timer = new Timer(
                                                                              const Duration(milliseconds: 500),
                                                                              () {
                                                                            setState(() {
                                                                              isPlaying = true;
                                                                              playingIndex = index;
                                                                              playAudio(Strings.comments[Strings.selectedCommentsIndex].replies![index].audio);
                                                                            });
                                                                          });
                                                                        } else {
                                                                          isPlaying =
                                                                              true;
                                                                          playingIndex =
                                                                              index;
                                                                          playAudio(Strings
                                                                              .comments[Strings.selectedCommentsIndex]
                                                                              .replies![index]
                                                                              .audio);
                                                                        }
                                                                      });
                                                                    },
                                                                    child: new Icon(
                                                                        Icons
                                                                            .play_arrow,
                                                                        size:
                                                                            28.0),
                                                                  )
                                                                : playingIndex ==
                                                                        index
                                                                    ? GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            isPlaying =
                                                                                false;
                                                                          });

                                                                          stopAudio();
                                                                        },
                                                                        child: new Icon(
                                                                            Icons
                                                                                .stop,
                                                                            size:
                                                                                28.0),
                                                                      )
                                                                    : GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            if (isPlaying ==
                                                                                true) {
                                                                              stopAudio();
                                                                              _timer = new Timer(const Duration(milliseconds: 500), () {
                                                                                setState(() {
                                                                                  isPlaying = true;
                                                                                  playingIndex = index;
                                                                                  playAudio(Strings.comments[Strings.selectedCommentsIndex].replies![index].audio);
                                                                                });
                                                                              });
                                                                            } else {
                                                                              isPlaying = true;
                                                                              playingIndex = index;
                                                                              playAudio(Strings.comments[Strings.selectedCommentsIndex].replies![index].audio);
                                                                            }
                                                                          });
                                                                        },
                                                                        child: new Icon(
                                                                            Icons
                                                                                .play_arrow,
                                                                            size:
                                                                                28.0),
                                                                      ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Slider(
                                                              value: playingIndex ==
                                                                      index
                                                                  ? audioCurrentlenth
                                                                      .toDouble()
                                                                  : 0,
                                                              min: 0,
                                                              max: playingIndex ==
                                                                      index
                                                                  ? audioLength
                                                                      .toDouble()
                                                                  : 0,
                                                              onChanged: (double
                                                                  value) {
                                                                setState(() {
                                                                  playingIndex ==
                                                                          index
                                                                      ? audioCurrentlenth =
                                                                          value
                                                                              .toInt()
                                                                      : 0;
                                                                  // _currentSliderValue = value;
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                  // Text(
                                                  //     Strings
                                                  //         .comments[Strings
                                                  //             .selectedCommentsIndex]
                                                  //         .replies[index]
                                                  //         .comment,
                                                  //     style: Drawables
                                                  //         .adddoccontentstyle(
                                                  //             Colors.black45,
                                                  //             14.0,
                                                  //             FontWeight.w400)),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              )),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
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
                                  color: Colors.grey[500]!,
                                )
                              ],
                            ));
                      }))
              : SizedBox(),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFFffffff),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 10,
                  child: MultiSelectDialogField<FetchMapedUsersData?>(
                    items: _userIitems,
                    title: Text("Tag Users"),
                    selectedColor: Color(0xFF0061b0),
                    decoration: BoxDecoration(
                      color: Color(0xFF0061b0).withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      border: Border.all(
                        color: Color(0xFF0061b0),
                        width: 2,
                      ),
                    ),
                    buttonIcon: Icon(
                      Icons.person,
                      color: Color(0xFF0061b0),
                    ),
                    buttonText: Text(
                      "Tag Users",
                      style: TextStyle(
                        color: Color(0xFF0061b0).withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (results) {
                      if (results.length > 0) {
                        tagedUsers = [];
                        tagedUsersId = [];
                        results.forEach((element) {
                          tagedUsers.add(element?.name);
                          tagedUsersId.add(element?.userId);
                        });
                      } else {
                        tagedUsers = [];
                        tagedUsersId = [];
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: MultiSelectDialogField<CatsData?>(
                    items: _catsItems,
                    title: Text("Tag Categories"),
                    selectedColor: Color(0xFF0061b0),
                    decoration: BoxDecoration(
                      color: Color(0xFF0061b0).withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      border: Border.all(
                        color: Color(0xFF0061b0),
                        width: 2,
                      ),
                    ),
                    buttonIcon: Icon(
                      Icons.category,
                      color: Color(0xFF0061b0),
                    ),
                    buttonText: Text(
                      "Tag Categories",
                      style: TextStyle(
                        color: Color(0xFF0061b0).withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (results) {
                      if (results.length > 0) {
                        tagedCats = [];
                        tagedCatsId = [];
                        results.forEach((element) {
                          tagedCats.add(element?.categoryName);
                          tagedCatsId.add(element?.categoryId);
                          // tagedCats = tagedCats + "," + element.categoryName;
                          // tagedCatsId = tagedCatsId.toString() +
                          //     "," +
                          //     element.categoryId.toString();
                        });
                      } else {
                        tagedCats = [];
                        tagedCatsId = [];
                      }
                      //_selectedAnimals = results;
                    },
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: showtoastinfo == true
                          ? Colors.grey[400]
                          : Colors.grey[300],
                      borderRadius: new BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      showtoastinfo == true
                          ? "Hold to record, release to send"
                          : "",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          ),
          Stack(children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white),
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/adddocComments');
                            },
                            child: Icon(Icons.attach_file)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Container(
                          width:MediaQuery.of(context).size.width * 0.6,
                          child: TextField(
                            controller: _msgcontroller,
                            onChanged: (value) {
                              if (value.length > 0) {
                                setState(() {
                                  typing = true;
                                });
                              } else {
                                setState(() {
                                  typing = false;
                                });
                              }
                            },
                            style: TextStyle(color: Colors.black),
                            focusNode: msgField,
                            decoration: InputDecoration(
                                hintText: startRecording == true
                                    ? elapsedTime
                                    : "Type your comment..",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                prefixIcon: FadeTransition(
                                  opacity: _animationController!,
                                  child: startRecording == true
                                      ? Icon(Icons.mic, color: Colors.red)
                                      : SizedBox(
                                          width: 0,
                                        ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: startRecording == true ? 10 : 15,
              bottom: startRecording == true ? 0 : 12,
              child: Container(
                width: startRecording == true ? 60 : 40,
                height: startRecording == true ? 60 : 40,
                decoration: BoxDecoration(
                    color: Color(0xFF0061b0),
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(50.0))),
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      startRecording = true;
                      startOrStop();
                      recordComments();
                    });
                  },
                  onLongPressEnd: (details) async {
                    // AppUtils.showToast(details.toString());
                    setState(() async {
                      startRecording = false;
                      startOrStop();
                      stopRecord();
                      sendAudio();
                    });
                  },
                  onTap: () {
                    if (typing == true) {
                      postReplies();
                    } else {
                      setState(() {
                        showtoastinfo = true;
                      });
                      _timer =
                          new Timer(const Duration(milliseconds: 2000), () {
                        setState(() {
                          showtoastinfo = false;
                        });
                      });
                    }
                  },
                  child: typing == false
                      ? Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 22,
                        )
                      : Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  getReplies() {
    _socket?.on("document-comments", (_data) {
      print('fromServer $_data');
      msgField.unfocus();
      setState(() {
        Strings.comments = [];
        for (var item in _data) {
          Strings.comments.add(CommentsRes.fromJson(item));
        }
        _timer = new Timer(const Duration(milliseconds: 1000), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(seconds: 1),
          );
          msgField.unfocus();
        });
      });
    });
  }

  recordComments() async {
    var dir = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      getPermission();
    } else {
      await _audioRecorder.start(
        path: dir! + "/MTARecordedAudio.wav",
        encoder: AudioEncoder.AAC,
      );
    }
  }

  stopRecord() async {
    await _audioRecorder.stop();
  }

  playAudio(url) async {
    // var dir = await ExtStorage.getExternalStoragePublicDirectory(
    //     ExtStorage.DIRECTORY_DOWNLOADS);
    // String url = dir + "/MTARecordedAudio.wav";
    await audioPlayer.play(Strings.baseImageUrl + url,
        volume: 5, stayAwake: false);
    audioPlayer.onDurationChanged.listen((Duration d) {
      int seconds = d.inSeconds;
      print('Max duration: $d');
      setState(() {
        audioLength = seconds;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      int seconds = p.inSeconds;
      print('curr duration: $p');
      setState(() {
        audioCurrentlenth = seconds;
      });
    });
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        audioLength = 0;
        audioCurrentlenth = 0;
        playingIndex = null;
        isPlaying = false;
      });
    });
    audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
    });
  }

  stopAudio() async {
    await audioPlayer.stop();
    setState(() {
      audioLength = 0;
      audioCurrentlenth = 0;
      playingIndex = null;
      isPlaying = false;
    });
  }

  sendAudio() async {
    AppUtils.showprogress();
    var dir = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    final bytesData =
        await Io.File(dir! + "/MTARecordedAudio.wav").readAsBytes();
    String base64Encodes(List<int> bytes) => base64.encode(bytes);
    String base64Encode = base64Encodes(bytesData);
    final api = Provider.of<ApiService>(context, listen: false);
    AudioReq req = AudioReq();
    req.audio = "data:audio/wav;base64," + base64Encode;
    req.categoryIdList = json.encode(tagedCatsId);
    req.categoryList = json.encode(tagedCats);
    req.documentId = Strings.category == true
        ? int.parse(Strings.selectedCatDocument[0].documentId!)
        : int.parse(Strings.selectedProDocument[0].documentId!);
    req.recipientId =
        json.encode(tagedUsers).replaceAll("'", "\'").replaceAll('"', "\'");
    req.recipient = json.encode(tagedUsersId);
    req.parent_comment_id =
        Strings.comments[Strings.selectedCommentsIndex].commentId;
    req.userId = Strings.userID;
    var dat = jsonEncode(req);
    print("Printing data -- > $dat");
    log("data--> $dat");
    api.uploadAudio(req).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        // _socket?.emit(
        //     'create-document-comment',
        //     json.encode({
        //       "project_id": Strings.selectedProject[0].projectId,
        //       "project_name": Strings.selectedProject[0].projectName,
        //       "audio": response.data,
        //       "comment": _msgcontroller.text,
        //       "document_id": Strings.category == true
        //           ? Strings.selectedCatDocument[0].documentId
        //           : Strings.selectedProDocument[0].documentId,
        //       'recipient_id': json.encode(tagedUsersId),
        //       'recipient': json.encode(tagedUsers),
        //       "category_id_list": json.encode(tagedCatsId),
        //       "category_list": json.encode(tagedCats),
        //       'parent_comment_id':
        //           Strings.comments[Strings.selectedCommentsIndex].commentId
        //     }));
        setState(() 
        {
          _socket?.disconnect();
          _socket?.connect();
          _socket?.on("connect", (_) {
            print('Connected');
            getReplies();
          });

          if (Strings.category == true) {
            Strings.selectedCatDocument[0].commentsCount =
                Strings.selectedCatDocument[0].commentsCount! + "1";
          } else {
            Strings.selectedProDocument[0].commentsCount =
                Strings.selectedProDocument[0].commentsCount! + "1";
          }
          tagedUsers = [];
          tagedUsersId = [];
          tagedCats = [];
          tagedCatsId = [];
          _msgcontroller.text = '';
          typing = false;
          // if (showscroll != true) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(seconds: 1),
          );
          msgField.unfocus();
          // } else {
          //   showscroll = false;
          // }
        });
      } else {
        AppUtils.showToastErrorTop(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  postReplies() {
    // print(json.encode(tagedUsersId.toString()));
    if (_msgcontroller.text.trim() == "") {
      AppUtils.showToastError("Please Enter Comments");
    } else {
      _socket?.emit(
          'create-document-comment',
          json.encode({
            "project_id": Strings.selectedProject[0].projectId,
            "project_name": Strings.selectedProject[0].projectName,
            "audio": "",
            "comment": _msgcontroller.text,
            "document_id": Strings.category == true
                ? Strings.selectedCatDocument[0].documentId
                : Strings.selectedProDocument[0].documentId,
            'recipient_id': json.encode(tagedUsersId),
            'recipient': json.encode(tagedUsers),
            "category_id_list": json.encode(tagedCatsId),
            "category_list": json.encode(tagedCats),
            'parent_comment_id':
                Strings.comments[Strings.selectedCommentsIndex].commentId
          }));

      // print(tagedUsers);
      // print(tagedCatsId);
      // print(tagedCats);
      setState(() {
        if (Strings.category == true) {
          Strings.selectedCatDocument[0].commentsCount =
              Strings.selectedCatDocument[0].commentsCount! + "1";
        } else {
          Strings.selectedProDocument[0].commentsCount =
              Strings.selectedProDocument[0].commentsCount! + "1";
        }
        tagedUsers = [];
        tagedUsersId = [];
        tagedCats = [];
        tagedCatsId = [];
        _msgcontroller.text = '';
        typing = false;
        // if (showscroll != true) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(seconds: 1),
        );
        msgField.unfocus();
        // } else {
        //   showscroll = false;
        // }
      });
    }
  }

  // postReplies() {
  //   if (_msgcontroller.text.trim() == "") {
  //     AppUtils.showToastError("Please Enter Reply");
  //   } else {
  //     _socket.emit(
  //         'create-document-comment',
  //         json.encode({
  //           "comment": _msgcontroller.text,
  //           "document_id": Strings.category == true
  //               ? Strings.selectedCatDocument[0].documentId
  //               : Strings.selectedProDocument[0].documentId,
  //           'recipient_id': tagedUsersId,
  //           'recipient': tagedUsers,
  //           "category_id_list": tagedCatsId,
  //           "category_list": tagedCats,
  //           'parent_comment_id':
  //               Strings.comments[Strings.selectedCommentsIndex].commentId
  //         }));
  //     setState(() {
  //       tagedUsers = "";
  //       tagedUsersId = "";
  //       tagedCats = "";
  //       tagedCatsId = "";
  //       _msgcontroller.text = '';
  //       _msgcontroller.text = '';
  //     });
  //   }
  // }

  static String calculateTimeDifferenceBetween({@required String? serverDate}) {
    DateTime startDate = DateTime.parse(serverDate!);
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

  startOrStop() {
    if (startStop) {
      startWatch();
    } else {
      stopWatch();
    }
  }

  reset() {
    watch.reset();
  }

  startWatch() {
    setState(() {
      startStop = false;
      watch.start();
      _timer = Timer.periodic(Duration(milliseconds: 100), updateTime);
    });
  }

  stopWatch() {
    setState(() {
      startStop = true;
      watch.stop();
      setTime();
      reset();
    });
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
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

void getPermission() async {
  var status = await Permission.microphone.status;
  if (status.isDenied) {
    await Permission.microphone.request();
  } else if (status.isPermanentlyDenied) {
    AppUtils.showToastError(
        "Please enable Microphone from App permission Settings");
  } else {
    await Permission.microphone.request();
  }
}
