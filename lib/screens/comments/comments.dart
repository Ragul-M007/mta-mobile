import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:io' as Io;
//import 'package:audioplayers/audio_cache.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/others/notification.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

List<FetchMapedUsersData> users = Strings.users;
List<CatsData> cats = Strings.categories;

AnimationController? _animationController;
AudioPlayer audioPlayer = AudioPlayer();
AudioCache audioCache = AudioCache();
var _userIitems = users
    .map((user) => MultiSelectItem<FetchMapedUsersData?>(user, user.name!))
    .toList();
var _catsItems = cats
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
var initialCommentCheck = true;

var isPlaying = false;
var playingIndex = null;
int audioLength = 0;
int audioCurrentlenth = 0;
Timer? _timer;
List<int> recordedData = [];
final _audioRecorder = Record();

String file64 = '';
String? fileExt;
IO.Socket? _socket;

class Comments extends StatefulWidget {
  static const String routeName = "/comments";

  const Comments({Key? key}) : super(key: key);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: Scaffold(
          appBar: appbar("Comments"),
          backgroundColor: Colors.grey[300],
          body: WillPopScope(
              child: CommentsContent(),
              onWillPop: () {
                initialCommentCheck = true;
                _socket?.disconnect();
                _socket?.dispose();
                if (Strings.fromNotificationComments == true) {
                  Strings.fromNotificationComments = false;
                  Navigator.pushNamed(context, '/dashboard');
                } else if (Strings.fromNotificationScren)
                {
                  Strings.fromNotificationScren = false;
                                Navigator.of(context).pushReplacementNamed('/notification');

                }
                
                 else {
                  Navigator.pushNamed(context, '/viewdoclist');
                }
                throw 'Screen Change';
              }),
        ));
  }
}

class CommentsContent extends StatefulWidget {
  static const String routeName = "/comments";

  @override
  _CommentsContentState createState() => _CommentsContentState();
}

class _CommentsContentState extends State<CommentsContent>
    with SingleTickerProviderStateMixin {
  var _currDoc;
  TextEditingController _msgcontroller = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  FocusNode msgField = new FocusNode();
  String? filepath;

  var _key;

  String? projectname;
  @override
  void initState() {
    super.initState();
    if(Strings.fromNotificationComments)
    {
      updateNotification(Strings.notificationID);
    }
    getUserCats();
    getuserCatgories();
    getProjectDetails();

    
    print("initial value check-->> $initialCommentCheck");
    initialCommentCheck = true;

    print("init state variable assigned--> $initialCommentCheck");
    Strings.pushNotify = false;
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    _animationController?.repeat(reverse: true);

    setState(() {
      tagedUsers = [];
      tagedUsersId = [];
      tagedCats = [];
      tagedCatsId = [];
      Strings.comments = [];
    });
    if (Strings.category == true) {
      _currDoc = Strings.selectedCatDocument[0];
    } else {
      _currDoc = Strings.selectedProDocument[0];
    }
    // getUserCats();
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'token': Strings.authToken,
        "document_id": _currDoc.documentId,
        'forceNew': false,
      }
    });
    _socket?.connect();
    AppUtils.showprogress();
    _socket?.on("connect", (_) {
      print('Connected');
      print("Calling function");
      getComments();
      //_socket?.disconnect();
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
  void dispose() {
    _animationController?.dispose();

    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
    Strings.pushNotify = true;
    tagedUsers = [];
    tagedUsersId = [];
    tagedCats = [];
    tagedCatsId = [];
    print("dispose variable assigned--> $initialCommentCheck");
    // Strings.comments = [];
  }

  getUserCats() {
    final api = Provider.of<ApiService>(context, listen: false);
    int projectid = int.parse(Strings.selectedProDocument[0].projectId ?? "71");

    api.fetchUsers(projectid).then((response) {
      if (response.status!) {
        setState(() {
          Strings.users = response.data!;
          users = response.data!;
          _userIitems = users
              .map((user) =>
                  MultiSelectItem<FetchMapedUsersData?>(user, user.name!))
              .toList();
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
 getProjectDetails() 
 {
   print("project details called");
    final api = Provider.of<ApiService>(context, listen: false);
    int projectid = int.parse(Strings.selectedProDocument[0].projectId ?? "71");
    api.getProjectName(projectid).then((response) {
      if (response.status!) {
        setState(() {
          print("project name ---> {response.data![0].projectName}");
        projectname = response.data![0].projectName ?? "";
        });
      } else {
        print('No categories');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print("Catched $onError");
    });
  }
  getuserCatgories() {
    final api = Provider.of<ApiService>(context, listen: false);
    int projectid = int.parse(Strings.selectedProDocument[0].projectId ?? "71");
    api.fetchCats(projectid).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        setState(() {
          Strings.categories = response.data!;
          cats = response.data!;
          _catsItems = cats
              .map((cats) =>
                  MultiSelectItem<CatsData?>(cats, cats.categoryName!))
              .toList();
        });
      } else {
        print('No categories');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print("Catched $onError");
    });
  }

  void _downloadfile(serverURL, filename) async {
    String? path;
    if (Platform.isAndroid) {
      path = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      print("ios");
      var vpath = await getApplicationDocumentsDirectory();
      String pathStr = vpath.toString();
      if (pathStr != null && pathStr.length >= 5) {
        path = pathStr.substring(12, pathStr.length);
      }
      if (path != null && path.length >= 1) {
        path = path.substring(0, path.length - 1);
      }
    }
    AppUtils.showprogress();
    AppUtils.showToast('Downloading');

    var filenames = serverURL.split("/");
    print("serverURL--> $serverURL");
    //var fileName = filename;//filenames[1];
    var extn = getFileExtension(serverURL);
    var nospace = filename.replaceAll(' ', '');
    var fileName = nospace + extn;
    print("url--> $fileName");
    String fullPath = "$path/$fileName";
    setState(() {
      filepath = fullPath;
    });
    var downloadedFile = await downloadFile(serverURL, fileName, path!);
    print("downloaded file $downloadedFile");
    openFile(downloadedFile);
  }

  Future<void> openFile(filePath) async {
    await OpenFile.open(filePath);
  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = Strings.baseImageUrl + url;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      print("printing url ---> $myUrl");
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else if (response.statusCode == 404) {
        AppUtils.dismissprogress();
        AppUtils.showToastError("Sorry, File  not Found !");
      } else {
        AppUtils.dismissprogress();
        filePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      AppUtils.dismissprogress();
      filePath = 'Can not fetch url';
    }
    AppUtils.dismissprogress();
    return filePath;
  }

  String getFileExtension(String fileName) {
    var file = fileName.split(".");
    var fileExt = file[1];
    if (fileExt == "png" || fileExt == "PNG") {
      return ".png";
    } else if (fileExt == "jpg" ||
        fileExt == "jepg" ||
        fileExt == "jpeg" ||
        fileExt == "JPG" ||
        fileExt == "JEPG" ||
        fileExt == "JPEG") {
      return ".jpg";
    } else if (fileExt == "pdf" || fileExt == "PDF") {
      return ".pdf";
    } else if (fileExt == "txt" || fileExt == "TXT") {
      return ".txt";
    } else if (fileExt == "ppt" || fileExt == "PPT") {
      return ".ppt";
    } else if (fileExt == "xls" ||
        fileExt == "xlsx" ||
        fileExt == "xlsm" ||
        fileExt == "xlsb" ||
        fileExt == "xltx") {
      return ".xls";
    } else {
      print("File extnsion--> $fileExt");
      return ".$fileExt";
    }
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
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Image.asset(
                          getFileExt((Strings.category == true)
                              ? Strings.selectedCatDocument[0].file
                              : Strings.selectedProDocument[0].file),
                          width: 30.0,
                          height: 30.0),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          Strings.category == true
                              ? "${Strings.selectedCatDocument[0].fileName}"
                              : "${Strings.selectedProDocument[0].fileName}",
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
                          // Strings.category == true
                          //     ? Strings.selectedCatDocument[0].commentsCount
                          //             .toString() +
                          //         " Comments"
                          //     : Strings.selectedProDocument[0].commentsCount
                          //             .toString() +
                          //         " Comments",
                          Strings.comments.length.toString(),
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600))
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, top: 5,bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Project: ${projectname ?? ""}",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w600)),
            )
          ),
          Divider(),
          Strings.comments.length > 0
              ? Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      controller: _scrollController,
                      itemCount: Strings.comments.length,
                      padding: EdgeInsets.all(20),
                      itemBuilder: (BuildContext ctx, int index) {
                        return Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                                    .comments[index].userImg!);
                                      },
                                      child: Container(
                                        width: 30.0,
                                        height: 30.0,
                                        decoration: new BoxDecoration(
                                          color:
                                              Color.fromRGBO(124, 148, 182, 1),
                                          image: new DecorationImage(
                                            image: new NetworkImage(
                                                Strings.baseImageUrl +
                                                    (Strings.comments[index]
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
                                                Strings.comments[index].name! +
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
                                          child: Text(Strings
                                                  .comments[index].recipient
                                                  ?.replaceAll('"', '') ??
                                              ""),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  (Strings.comments[index]
                                                                  .audio ==
                                                              "" ||
                                                          Strings
                                                                  .comments[
                                                                      index]
                                                                  .audio ==
                                                              null)
                                                      ? Text(
                                                          Strings
                                                              .comments[index]
                                                              .comment
                                                              .toString(),
                                                          style: Drawables
                                                              .adddoccontentstyle(
                                                                  Colors
                                                                      .black45,
                                                                  14.0,
                                                                  FontWeight
                                                                      .w400))
                                                      : (Strings.comments[index]
                                                              .audio!
                                                              .contains(".wav"))
                                                          ? Row(
                                                              children: [
                                                                isPlaying ==
                                                                        false
                                                                    ? GestureDetector(
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
                                                                                  playAudio(Strings.comments[index].audio);
                                                                                });
                                                                              });
                                                                            } else {
                                                                              isPlaying = true;
                                                                              playingIndex = index;
                                                                              playAudio(Strings.comments[index].audio);
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
                                                                              setState(() {
                                                                                isPlaying = false;
                                                                              });

                                                                              stopAudio();
                                                                            },
                                                                            child:
                                                                                new Icon(Icons.stop, size: 28.0),
                                                                          )
                                                                        : GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                if (isPlaying == true) {
                                                                                  stopAudio();
                                                                                  _timer = new Timer(const Duration(milliseconds: 500), () {
                                                                                    setState(() {
                                                                                      isPlaying = true;
                                                                                      playingIndex = index;
                                                                                      playAudio(Strings.comments[index].audio);
                                                                                    });
                                                                                  });
                                                                                } else {
                                                                                  isPlaying = true;
                                                                                  playingIndex = index;
                                                                                  playAudio(Strings.comments[index].audio);
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                new Icon(Icons.play_arrow, size: 28.0),
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
                                                                  onChanged:
                                                                      (double
                                                                          value) {
                                                                    setState(
                                                                        () {
                                                                      playingIndex ==
                                                                              index
                                                                          ? audioCurrentlenth =
                                                                              value.toInt()
                                                                          : 0;
                                                                      // _currentSliderValue = value;
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                _downloadfile(
                                                                    Strings
                                                                        .comments[
                                                                            index]
                                                                        .audio,
                                                                    Strings
                                                                        .comments[
                                                                            index]
                                                                        .commentId
                                                                        .toString());
                                                              },
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Stack(
                                                                      children: [
                                                                        Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.1),
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          padding:
                                                                              EdgeInsets.all(10),
                                                                          child:
                                                                              Image.asset(
                                                                            getFileExt(Strings.comments[index].audio ??
                                                                                "test.mpg"),
                                                                            width:
                                                                                80,
                                                                            height:
                                                                                80,
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top:
                                                                              20,
                                                                          left:
                                                                              40,
                                                                          child: Container(
                                                                              child: Icon(
                                                                            Icons.download_rounded,
                                                                            size:
                                                                                20.0,
                                                                          )),
                                                                        ),
                                                                      ]),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                        Strings.comments[index].comment ==
                                                                                "undefined"
                                                                            ? ""
                                                                            : Strings.comments[index].comment ??
                                                                                "",
                                                                        maxLines:
                                                                            20,
                                                                        style: Drawables.adddoccontentstyle(
                                                                            Colors.black45,
                                                                            14.0,
                                                                            FontWeight.w400)),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
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
                                                              .replies!.length
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
                                  color: Colors.grey[500]!,
                                )
                              ],
                            ));
                      }))
              : Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFFffffff),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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

                            print("Added data");
                            // tagedCats = tagedCats + "," + element.categoryName;
                            // tagedCatsId = tagedCatsId.toString() +
                            //     "," +
                            //     element.categoryId.toString();
                          });
                          results = [];
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
          ),
          // SizedBox(height: 10),
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
                          width: MediaQuery.of(context).size.width * 0.6,
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
                      postComments();
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

  getComments() async 
  {
    print("Getting comments");
    _socket?.on("document-comments", (_data) 
    {

      print('fromServer');

      if (initialCommentCheck) 
      {
        log('fromServer comments $_data');
        setState(() 
        {
          print("Dta chacek--> $initialCommentCheck");
          print("getting inside");
          msgField.unfocus();
            Strings.comments = [];
            for (var item in _data) {
                Strings.comments.add(CommentsRes.fromJson(item));
                print("set state");
            }
            setState(() {
              initialCommentCheck = false;
            print("Comments fetched changing to false");
            // _socket?.dispose();
            _timer = new Timer(const Duration(milliseconds: 1000), () 
            {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                curve: Curves.fastOutSlowIn,
                duration: const Duration(seconds: 1),
              );
              msgField.unfocus();
              Strings.selectedProDocument[0].commentsCount =
                  Strings.comments.length.toString();
            });
          });
        });
      }
      setState(() {
          print(initialCommentCheck);
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
    ;
  }

  Future<void> stopRecord() async {
    _audioRecorder.stop();
  }

  playAudio(url) async {
    // var dir = await ExtStorage.getExternalStoragePublicDirectory(
    //     ExtStorage.DIRECTORY_DOWNLOADS);
    // String url = dir + "/MTARecordedAudio.wav";
    print(Strings.baseImageUrl + url);
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

  getDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      final bytes = await Io.File(file.path!).readAsBytes();
      String base64Encodes(List<int> bytes) => base64.encode(bytes);
      String base64Encode = base64Encodes(bytes); //base64.encode(bytes);
      file64 = base64Encode;
      fileExt = file.extension;
      // print(bytes);
      // print(base64Encode);
      // print(file.size);
      // print(file.extension);
      // print(file.path);
      setState(() {
        // var title = file.name.split(".");
        // docTitle.text = title[0];
      });
    } else {
      // User canceled the picker
    }
  }

  sendAudio() async {
    AppUtils.showprogress();
    var dir = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    print("direct $dir");
    final bytesData =
        await Io.File(dir! + "/MTARecordedAudio.wav").readAsBytes();
    String base64Encodes(List<int> bytes) => base64.encode(bytes);
    String base64Encode = base64Encodes(bytesData);
    final api = Provider.of<ApiService>(context, listen: false);
    AudioReq req = AudioReq();
    print("taggedID--> ${tagedCatsId.length}");

    req.audio = "data:audio/wav;base64," + base64Encode;

    req.categoryIdList = json.encode(tagedCatsId);
    req.categoryList = json.encode(tagedCats);
    //var removeQuotes =  json.encode(tagedCats).replaceAll("", '');
    //print("removeQuotes---> $removeQuotes");

    req.documentId = Strings.category == true
        ? int.parse(Strings.selectedCatDocument[0].documentId!)
        : int.parse(Strings.selectedProDocument[0].documentId!);
    req.recipientId =
        json.encode(tagedUsers).replaceAll("'", "\'").replaceAll('"', "\'");
    req.recipient = json.encode(tagedUsersId);

    req.userId = Strings.userID;
    var dat = jsonEncode(req);
    print("Printing data -- > $dat");
    log("data--> $dat");
    // var audioRequest = json.encode({
    //           "audio": "data:audio/wav;base64," + base64Encode,
    //           "category_id_list": json.encode(tagedCatsId),
    //           "category_list": json.encode(tagedCats),
    //           "document_id": Strings.category == true
    //               ? Strings.selectedCatDocument[0].documentId
    //               : Strings.selectedProDocument[0].documentId,
    //           'recipient_id': json.encode(tagedUsersId),
    //           'user_id': Strings.userID,

    //         });
    //         print(audioRequest);
    // print("base64Encode--> $base64Encode");
    api.uploadAudio(req).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        // _socket?.emit(
        //     'create-document-comment',
        //     // json.encode({
        //     //   "project_id": Strings.selectedProject[0].projectId,
        //     //   "project_name": Strings.selectedProject[0].projectName,
        //     //   "audio": response.data,
        //     //   "comment": _msgcontroller.text,
        //     //   "document_id": Strings.category == true
        //     //       ? Strings.selectedCatDocument[0].documentId
        //     //       : Strings.selectedProDocument[0].documentId,
        //     //   'recipient_id': json.encode(tagedUsersId),
        //     //   'recipient': json.encode(tagedUsers),
        //     //   "category_id_list": json.encode(tagedCatsId),
        //     //   "category_list": json.encode(tagedCats)
        //     // })
        //      );

        setState(() {
          _socket?.disconnect();
          _socket?.connect();
          _socket?.on("connect", (_) {
            print('Connected');
            getComments();
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

  postComments() {
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
            "user_id": Strings.userID
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
        initialCommentCheck = true;
        getComments();
      });
    }
  }
  updateNotification(notificationId) {
    final api = Provider.of<ApiService>(context, listen: false);
    api.updateNotificationStatus(notificationId).then((response) {
      if (response.status!) {
       // AppUtils.showToastError("Unable to update status");
      } else {
        AppUtils.dismissprogress();
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError("Unable to connect to server");
      print(onError.toString());
    });
  }

  String getFileExt(String? fileName) {
    print("Filename--> $fileName");
    var file = fileName?.split(".");
    var fileExt = file?[1];
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
    } else if (fileExt == "mpeg" || fileExt == "mpg") {
      return "assets/icons/mpg.png";
    } else if (fileExt == "mp4") {
      return "assets/icons/mpg.png";
    }
     else if (fileExt == "wav" || fileExt == "mp3") {
      return "assets/icons/mp3.png";
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

  static String calculateTimeDifferenceBetween({@required String? serverDate}) {
    DateTime startDate = DateTime.parse(serverDate!);
    //print(DateFormat.MMMEd().format(startDate));
    DateTime endDate = DateTime.now();

    // var dateUtc = DateTime.now().toUtc();
    // var strToDateTime = DateTime.parse(dateUtc.toString());
    // final convertLocal = strToDateTime.toLocal();
    // var newFormat = DateFormat("yy-MM-dd hh:mm:ss aaa");
    // String updatedDt = newFormat.format(convertLocal);
    // print(dateUtc);
    // print(convertLocal);
    // print(updatedDt);

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
