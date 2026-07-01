import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:io' as Io;
//import 'package:audioplayers/audio_cache.dart';
import 'package:dio/dio.dart';
import 'package:mta/utilities/external_path_helper.dart';
import 'package:flutter/foundation.dart';
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
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';

List<FetchMapedUsersData> users = Strings.users;
List<CatsData> cats = Strings.categories;
List<CatsData?> CatData = [];
List<FetchMapedUsersData?> UserData = [];

AnimationController? _animationController;
AudioPlayer audioPlayer = AudioPlayer();
AudioCache audioCache = AudioCache();
var dio = Dio();
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
var uniqueRecordId;

var isPlaying = false;
var playingIndex;
int audioLength = 0;
int audioCurrentlenth = 0;
Timer? _timer;
List<int> recordedData = [];
final _audioRecorder = AudioRecorder();
String? filepath;
IO.Socket? _socket;
int? projectId;
String? projectname = "";

class ProjectCommentsReplies extends StatefulWidget {
  static const String routeName = "/projectCommentReplies";

  @override
  _ProjectCommentsRepliesState createState() => _ProjectCommentsRepliesState();
}

class _ProjectCommentsRepliesState extends State<ProjectCommentsReplies> {
  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: appbar("Replies"),
            backgroundColor: Colors.grey[300],
            body: WillPopScope(
                onWillPop: () {
                  Strings.categoriesforReply = false;
                  _socket?.disconnect();
                  _socket?.dispose();
                  Navigator.pushNamed(context, '/projectComments');
                  throw 'Replies';
                },
                child: RepliesContent()),
          ),
        ));
  }
}

class RepliesContent extends StatefulWidget {
  static const String routeName = "/projectCommentReplies";

  @override
  _RepliesContentState createState() => _RepliesContentState();
}

class _RepliesContentState extends State<RepliesContent>
    with SingleTickerProviderStateMixin {
  var _currDoc;

  TextEditingController _msgcontroller = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  FocusNode msgField = new FocusNode();

  @override
  void initState() {
    super.initState();
    Strings.pushNotify = false;
    initialCommentCheck = true;
    uniqueRecordId = Uuid().v1();
    if (Strings.fromNotificationComments) {
      updateNotification(Strings.notificationID);
    }
    projectId = Strings.projectId;
    // if(Strings.categoriesforReply)
    // {
    //     projectId = Strings.selectedProject[0].projectId!;
    // }
    // else
    // {
    //     projectId = int.parse(Strings.selectedProDocument[0].projectId ?? "0");
    // }
    getUserCats();
    getuserCatgories();
    getProjectDetails();
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    _animationController?.repeat(reverse: true);

    tagedUsers = [];
    tagedUsersId = [];
    tagedCats = [];
    tagedCatsId = [];
    // Strings.comments = [];

    // if (Strings.categoriesforReply == true) {
    //   _currDoc = Strings.selectedCatDocument[0];
    // } else {
    //   _currDoc = Strings.selectedProDocument[0];
    // }
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': Strings.authToken, "project_id": projectId}
    });
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected init');
      getReplies();
    });

    _socket?.onDisconnect((_) => print('Connected dis'));
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

  getUserCats() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchUsers(projectId!).then((response) {
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

  getProjectDetails() {
    print("project details called");
    final api = Provider.of<ApiService>(context, listen: false);

    api.getProjectName(projectId!).then((response) {
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

    api.fetchCats(projectId!).then((response) {
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

  getIndex() {
    for (int i = 0; i < Strings.comments.length; i++) {
      print(
          " String data from comments${Strings.comments[i].commentId.toString()}");

      print(" Stored comment id ${Strings.selectedProDocument[0].commentId}");

      if (Strings.comments[i].commentId.toString() ==
          Strings.selectedProDocument[0].commentId.toString()) {
        print("inside");
        setState(() {
          Strings.selectedCommentsIndex = i;

          print("selected comment index is $i");
        });
      }
    }
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
    } else if (fileExt == "wav" || fileExt == "mp3") {
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

  void _downloadfile(serverURL, filename) async {
    String? path;
    if (Platform.isAndroid) {
      path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      print("ios");
      var vpath = await getApplicationDocumentsDirectory();
      String pathStr = vpath.toString();
      if (pathStr.length >= 5) {
        path = pathStr.substring(12, pathStr.length);
      }
      if (path != null && path.length >= 1) {
        path = path.substring(0, path.length - 1);
      }
    }
    // AppUtils.showprogress();
    // AppUtils.showToast('Downloading');

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
    var downloadedFile = await download2(dio, serverURL, '$path/$fileName');
    // var downloadedFile = await downloadFile(serverURL, fileName, path!);
    print("downloaded file $downloadedFile");
    openFile(downloadedFile);
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      var myUrl = Strings.baseImageUrl + url;
      Response response = await dio.get(
        myUrl,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
      var filePath;
      if (response.statusCode == 200) {
        AppUtils.dismissprogress();
        filePath = savePath;
        file = File(filePath);
      } else if (response.statusCode == 404) {
        AppUtils.dismissprogress();
        AppUtils.showToastError("Sorry, File  not Found !");
      } else {
        AppUtils.dismissprogress();
        filePath = 'Error code: ' + response.statusCode.toString();
      }
      return filePath;
    } catch (e) {
      AppUtils.dismissprogress();
      var filePath = 'Error $e';
      print(e);
      return filePath;
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      AppUtils.showprogresswithpercent(received / total);
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  Future<void> openFile(filePath) async {
    await OpenFilex.open(filePath);
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

  Future<bool> showDeleteDialog(ctx, commentId) async {
    return await showDialog(
      context: ctx,
      builder: (context) => new AlertDialog(
        title: Text(
          "Delete ?",
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF0061b0),
              fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure to delete the Comment?',
          style: TextStyle(
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              'No',
              style: TextStyle(
                  fontSize: 16, color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              final api = Provider.of<ApiService>(context, listen: false);
              Navigator.of(context).pop(false);
              AppUtils.showprogress();
              api.removeComment(commentId).then((response) {
                AppUtils.dismissprogress();
                if (response.status!) {
                  AppUtils.showToastSuccess("Comment deleted successfully");
                  _socket?.disconnect();
                  _socket?.connect();
                  _socket?.on("connect", (_) {
                    initialCommentCheck = true;
                    getReplies();
                  });
                } else {
                  print("delete failed");
                }
              }).catchError((onError) {
                AppUtils.dismissprogress();
                print(onError.toString());
              });
            },
            child: new Text(
              'Yes',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    _socket?.disconnect();
    _socket?.dispose();
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
    print("Refreshed");
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
                                          .comments[
                                              Strings.selectedCommentsIndex]
                                          .userImg!);
                            },
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: Strings
                                          .comments[
                                              Strings.selectedCommentsIndex]
                                          .userImg !=
                                      null
                                  ? NetworkImage(Strings.baseImageUrl +
                                      (Strings
                                          .comments[
                                              Strings.selectedCommentsIndex]
                                          .userImg!))
                                  : AssetImage("assets/icons/account.png")
                                      as ImageProvider,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                            )),
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
                                          : Image.asset(
                                              getFileExt(
                                                Strings
                                                    .comments[Strings
                                                        .selectedCommentsIndex]
                                                    .audio,
                                              ),
                                              width: 30,
                                              height: 30),
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
          Strings.comments[Strings.selectedCommentsIndex].replies!.length > 0
              ? Expanded(
                  child: ScrollablePositionedList.builder(
                      //shrinkWrap: true,
                      reverse: true,
                      itemScrollController: itemScrollController,
                      itemPositionsListener: itemPositionsListener,
                      padding: EdgeInsets.all(20),
                      itemCount: Strings.comments[Strings.selectedCommentsIndex]
                          .replies!.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return ((Strings.comments[Strings.selectedCommentsIndex]
                                            .replies![index].recipient ??
                                        "[]")
                                    .contains(Strings.userID.toString()) ||
                                Strings.comments[Strings.selectedCommentsIndex]
                                        .replies![index].recipient ==
                                    "[]" ||
                                Strings.comments[Strings.selectedCommentsIndex]
                                        .replies![index].commentUserId ==
                                    Strings.userID)
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          child: CircleAvatar(
                                            radius: 10,
                                            backgroundImage: Strings
                                                        .comments[Strings
                                                            .selectedCommentsIndex]
                                                        .replies![index]
                                                        .userImg !=
                                                    null
                                                ? NetworkImage(Strings
                                                        .baseImageUrl +
                                                    (Strings
                                                        .comments[Strings
                                                            .selectedCommentsIndex]
                                                        .replies![index]
                                                        .userImg!))
                                                : AssetImage(
                                                        "assets/icons/account.png")
                                                    as ImageProvider,
                                            backgroundColor:
                                                Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
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
                                            SizedBox(height: 3),
                                            (Strings
                                                            .comments[Strings
                                                                .selectedCommentsIndex]
                                                            .replies![index]
                                                            .recipient !=
                                                        "[]" ||
                                                    Strings
                                                            .comments[Strings
                                                                .selectedCommentsIndex]
                                                            .replies![index]
                                                            .categoryList !=
                                                        "[]")
                                                ? Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Strings
                                                                    .comments[
                                                                        Strings
                                                                            .selectedCommentsIndex]
                                                                    .replies![
                                                                        index]
                                                                    .recipient !=
                                                                "[]"
                                                            ? Container(
                                                                child: Text(
                                                                    Strings.comments[Strings.selectedCommentsIndex].replies![index].recipient?.replaceAll('"',
                                                                                '') ==
                                                                            "[]"
                                                                        ? ""
                                                                        : Strings.comments[Strings.selectedCommentsIndex].replies![index].recipient?.replaceAll('"',
                                                                                '') ??
                                                                            "",
                                                                    maxLines:
                                                                        10,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              )
                                                            : Container(),
                                                        Strings
                                                                    .comments[
                                                                        Strings
                                                                            .selectedCommentsIndex]
                                                                    .replies![
                                                                        index]
                                                                    .categoryList !=
                                                                "[]"
                                                            ? Container(
                                                                child: Text(
                                                                    Strings.comments[Strings.selectedCommentsIndex].replies![index].categoryList?.replaceAll('"',
                                                                                '') ==
                                                                            "[]"
                                                                        ? ""
                                                                        : Strings.comments[Strings.selectedCommentsIndex].replies![index].categoryList?.replaceAll('"',
                                                                                '') ??
                                                                            "",
                                                                    maxLines:
                                                                        10,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            Container(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                                    .comments[
                                                                        Strings
                                                                            .selectedCommentsIndex]
                                                                    .replies![
                                                                        index]
                                                                    .comment
                                                                    .toString(),
                                                                style: Drawables
                                                                    .adddoccontentstyle(
                                                                        Colors
                                                                            .black45,
                                                                        14.0,
                                                                        FontWeight
                                                                            .w400))
                                                            : (Strings
                                                                    .comments[
                                                                        Strings
                                                                            .selectedCommentsIndex]
                                                                    .replies![
                                                                        index]
                                                                    .audio!
                                                                    .contains(
                                                                        ".wav"))
                                                                ? Row(
                                                                    children: [
                                                                      isPlaying ==
                                                                              false
                                                                          ? GestureDetector(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  if (isPlaying == true) {
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
                                                                              child: new Icon(Icons.play_arrow, size: 28.0),
                                                                            )
                                                                          : playingIndex == index
                                                                              ? GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      isPlaying = false;
                                                                                    });

                                                                                    stopAudio();
                                                                                  },
                                                                                  child: new Icon(Icons.stop, size: 28.0),
                                                                                )
                                                                              : GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      if (isPlaying == true) {
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
                                                                                  child: new Icon(Icons.play_arrow, size: 28.0),
                                                                                ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Slider(
                                                                        value: playingIndex ==
                                                                                index
                                                                            ? audioCurrentlenth.toDouble()
                                                                            : 0,
                                                                        min: 0,
                                                                        max: playingIndex ==
                                                                                index
                                                                            ? audioLength.toDouble()
                                                                            : 0,
                                                                        onChanged:
                                                                            (double
                                                                                value) {
                                                                          setState(
                                                                              () {
                                                                            playingIndex == index
                                                                                ? audioCurrentlenth = value.toInt()
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
                                                                              .comments[Strings
                                                                                  .selectedCommentsIndex]
                                                                              .replies![
                                                                                  index]
                                                                              .audio,
                                                                          Strings
                                                                              .comments[Strings.selectedCommentsIndex]
                                                                              .replies![index]
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
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.grey.withOpacity(0.1),
                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                ),
                                                                                padding: EdgeInsets.all(10),
                                                                                child: Image.asset(
                                                                                  getFileExt(Strings.comments[Strings.selectedCommentsIndex].replies![index].audio ?? "test.mpg"),
                                                                                  width: 80,
                                                                                  height: 80,
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                top: 20,
                                                                                left: 40,
                                                                                child: Container(
                                                                                    child: Icon(
                                                                                  Icons.download_rounded,
                                                                                  size: 20.0,
                                                                                )),
                                                                              ),
                                                                            ]),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Expanded(
                                                                          child: Text(
                                                                              Strings.comments[Strings.selectedCommentsIndex].replies![index].comment ?? "",
                                                                              maxLines: 20,
                                                                              style: Drawables.adddoccontentstyle(Colors.black45, 14.0, FontWeight.w400)),
                                                                        )
                                                                      ],
                                                                    ),
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
                                                    ),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadiusDirectional
                                                                .circular(10)),
                                                  ),
                                                  Strings.userID ==
                                                          Strings
                                                              .comments[Strings
                                                                  .selectedCommentsIndex]
                                                              .replies![index]
                                                              .commentUserId
                                                      ? IconButton(
                                                          onPressed: () {
                                                            showDeleteDialog(
                                                                context,
                                                                Strings
                                                                    .comments[
                                                                        Strings
                                                                            .selectedCommentsIndex]
                                                                    .replies![
                                                                        index]
                                                                    .commentId);
                                                          },
                                                          icon: Icon(
                                                              Icons.delete))
                                                      : SizedBox()
                                                ],
                                              ),
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
                                ))
                            : Container();
                      }))
              : Spacer(),
          (tagedUsers.length > 0 || tagedCats.length > 0)
              ? Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 10, 0, 10),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tagedUsers.length > 0
                              ? Text("Tagged Users:",
                                  style: TextStyle(color: Colors.grey[800]))
                              : SizedBox(),
                          Wrap(
                            spacing: 2.0,
                            children: List<Widget>.generate(
                              tagedUsers.length,
                              (int index) {
                                return ChoiceChip(
                                  disabledColor: Colors.grey.withOpacity(0.2),
                                  label: Text(tagedUsers[index],
                                      style: TextStyle(color: Colors.black)),
                                  selected: false,
                                );
                              },
                            ).toList(),
                          ),
                          tagedCats.length > 0
                              ? Text("Tagged Categories:",
                                  style: TextStyle(color: Colors.grey[800]))
                              : SizedBox(),
                          Wrap(
                            spacing: 2.0,
                            children: List<Widget>.generate(
                              tagedCats.length,
                              (int index) {
                                return ChoiceChip(
                                  disabledColor: Colors.grey.withOpacity(0.2),
                                  label: Text(
                                    tagedCats[index],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  selected: false,
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
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
                              _socket?.disconnect();
                              Strings.fromReplies = true;
                              Strings.documentUploadfromProject = true;
                              Navigator.pushNamed(context, '/adddocComments');
                            },
                            child: Icon(Icons.attach_file)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
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
                        IconButton(
                            onPressed: () {
                              showTagBottomSheet();
                            },
                            icon: Icon(Icons.bookmarks_sharp))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: startRecording == true ? 10 : 15,
              bottom: startRecording == true ? 12 : 32,
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
                      AppUtils.showToastError("Please enter the Comments");
                      //   setState(() {
                      //     showtoastinfo = true;
                      //   });
                      //   _timer =
                      //       new Timer(const Duration(milliseconds: 2000), () {
                      //     setState(() {
                      //       showtoastinfo = false;
                      //     });
                      //   });
                    }
                  },
                  child:
                      // typing == false
                      //     ? Icon(
                      //         Icons.mic,
                      //         color: Colors.white,
                      //         size: 22,
                      //       )
                      //   :
                      Icon(
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

  showTagBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return new ConstrainedBox(
          constraints: new BoxConstraints(),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: MultiSelectDialogField<FetchMapedUsersData?>(
                    initialValue: UserData,
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
                    // onConfirm: (res) {},
                    onConfirm: (results) {
                      UserData = results;
                      if (results.length > 0) {
                        setState(() {
                          tagedUsers = [];
                          tagedUsersId = [];
                          results.forEach((element) {
                            if (!tagedUsers.contains(element?.name)) {
                              tagedUsers.add(element?.name);
                            }
                            if (!tagedUsersId.contains(element?.userId)) {
                              tagedUsersId.add(element?.userId);
                            }
                          });
                        });
                      } else {
                        tagedUsers = [];
                        tagedUsersId = [];
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: MultiSelectDialogField<CatsData?>(
                    initialValue: CatData,
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
                    // onConfirm: (res) {},
                    onConfirm: (results) {
                      if (results.length > 0) {
                        setState(() {
                          tagedCats = [];
                          tagedCatsId = [];
                          CatData = results;
                          results.forEach((element) {
                            if (!tagedCats.contains(element?.categoryName)) {
                              tagedCats.add(element?.categoryName);
                            }
                            if (!tagedCatsId.contains(element?.categoryId)) {
                              tagedCatsId.add(element?.categoryId);
                            }
                          });
                        });
                        results = [];
                      } else {
                        tagedCats = [];
                        tagedCatsId = [];
                      }
                      //_selectedAnimals = results;
                    },
                  ),
                ),
                ElevatedButton(
                  child: const Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);

                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  getReplies() async {
    print("Getting replied");
    _socket?.on("project-comments", (_data) {
      log('fromServer $_data');
      print("initial check $initialCommentCheck");
      if (initialCommentCheck) {
        print("dataaa $_data");
        print("validation passed");
        Strings.comments = [];
        for (var item in _data) {
          Strings.comments.add(CommentsRes.fromJson(item));
        }
        if (Strings.fromNotificationComments || Strings.fromNotificationReply) {
          getIndex();
        }
        print("chnaging initaial value to false");
        initialCommentCheck = false;

        print(
            "length  ${Strings.comments[Strings.selectedCommentsIndex].replies?.length}");
        if (Strings.comments[Strings.selectedCommentsIndex].replies!.length >
            1) {
          itemScrollController.jumpTo(
              index: Strings
                  .comments[Strings.selectedCommentsIndex].replies!.length);
          msgField.unfocus();
        }
        setState(() {
          print("val");
        });
      }
    });
  }

  recordComments() async {
    var path;
    if (Platform.isAndroid) {
//       Directory tempDir = await getTemporaryDirectory();
// path = tempDir.path;
      path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      print("ios");
      var vpath = await getApplicationDocumentsDirectory();
      String pathStr = vpath.toString();
      if (pathStr.length >= 5) {
        path = pathStr.substring(12, pathStr.length);
      }
      if (path != null && path.length >= 1) {
        path = path.substring(0, path.length - 1);
      }
    }
    final status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      AppUtils.showToastError(
          "Please enable Microphone from App permission Settings");
      return;
    }
    if (!status.isGranted) return;
    String filePath = path + '/' + "${uniqueRecordId}_mta12" + '.m4a';

    print("tteyyyy $filePath");
    await _audioRecorder.start(
      const RecordConfig(),
      path: filePath,
    );
  }

  stopRecord() async {
    await _audioRecorder.stop();
  }

  playAudio(url) async {
    // var dir = await ExtStorage.getExternalStoragePublicDirectory(
    //     ExtStorage.DIRECTORY_DOWNLOADS);
    // String url = dir + "/MTARecordedAudio.wav";
    await audioPlayer.play(UrlSource(Strings.baseImageUrl + url), volume: 5);
    audioPlayer.onDurationChanged.listen((Duration d) {
      int seconds = d.inSeconds;
      print('Max duration: $d');
      setState(() {
        audioLength = seconds;
      });
    });
    audioPlayer.onPositionChanged.listen((Duration p) {
      int seconds = p.inSeconds;
      print('curr duration: $p');
      setState(() {
        audioCurrentlenth = seconds;
      });
    });
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        audioLength = 0;
        audioCurrentlenth = 0;
        playingIndex = null;
        isPlaying = false;
      });
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
    var path;

    if (Platform.isAndroid) {
//       Directory tempDir = await getTemporaryDirectory();
// path = tempDir.path;
      path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      print("ios");
      var vpath = await getApplicationDocumentsDirectory();
      String pathStr = vpath.toString();
      if (pathStr.length >= 5) {
        path = pathStr.substring(12, pathStr.length);
      }
      if (path != null && path.length >= 1) {
        path = path.substring(0, path.length - 1);
      }
    }
    String filePath = path + '/' + "${uniqueRecordId}_mta12" + '.m4a';
    final bytesData = await Io.File(filePath).readAsBytes();
    String base64Encodes(List<int> bytes) => base64.encode(bytes);
    String base64Encode = base64Encodes(bytesData);
    final api = Provider.of<ApiService>(context, listen: false);
    AudioReq req = AudioReq();
    req.audio = "data:audio/wav;base64," + base64Encode;
    req.categoryIdList = json.encode(tagedCatsId);
    req.categoryList = json.encode(tagedCats);
    req.recipientId =
        json.encode(tagedUsers).replaceAll("'", "\'").replaceAll('"', "\'");
    req.recipient = json.encode(tagedUsersId);
    req.parent_comment_id =
        Strings.comments[Strings.selectedCommentsIndex].commentId;
    req.userId = Strings.userID;
    req.projectId = Strings.selectedProject[0].projectId;
    var dat = jsonEncode(req);
    print("Printing data -- > $dat");
    log("data--> $dat");
    api.uploadAudio(req).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        _socket?.disconnect();
        _socket?.connect();
        UserData.clear();
        tagedCats.clear();
        tagedCatsId.clear();
        tagedUsers.clear();
        tagedUsersId.clear();
        initialCommentCheck = true;
        AppUtils.showToastSuccess("Audio sent successfully");
        CatData.clear();
        _socket?.on("connect", (_) {
          getReplies();

          // if (Strings.categoriesforReply == true) {
          //   Strings.selectedCatDocument[0].commentsCount =
          //       Strings.selectedCatDocument[0].commentsCount! + "1";
          // } else {
          //   Strings.selectedProDocument[0].commentsCount =
          //       Strings.selectedProDocument[0].commentsCount! + "1";
          // }
          // tagedUsers = [];
          // tagedUsersId = [];
          // tagedCats = [];
          // tagedCatsId = [];
          _msgcontroller.text = '';
          typing = false;
          // if (showscroll != true) {
          // _scrollController.animateTo(
          //   _scrollController.position.maxScrollExtent,
          //   curve: Curves.fastOutSlowIn,
          //   duration: const Duration(seconds: 1),
          // );
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
    print("Posting replies");
    // print(json.encode(tagedUsersId.toString()));
    if (_msgcontroller.text.trim() == "") {
      AppUtils.showToastError("Please Enter Comments");
    } else {
      _socket?.emitWithAck(
          'create-project-comment',
          json.encode({
            "project_id": projectId,
            "project_name": projectname,
            "audio": "",
            "comment": _msgcontroller.text,
            'recipient_id': json.encode(tagedUsersId),
            'recipient': json.encode(tagedUsers),
            "category_id_list": json.encode(tagedCatsId),
            "category_list": json.encode(tagedCats),
            'parent_comment_id':
                Strings.comments[Strings.selectedCommentsIndex].commentId,
            "user_id": Strings.userID
          }), ack: (datal) {
        print('ack $datal');
        if (datal != null) {
          print('from server $datal');
        } else {
          print("Null");
        }
      });
      AppUtils.showToastSuccess("Comment sent successfully");
      initialCommentCheck = true;

      // print(tagedUsers);
      // print(tagedCatsId);
      // print(tagedCats);

      // if (Strings.categoriesforReply == true) {
      //   Strings.selectedCatDocument[0].commentsCount =
      //       Strings.selectedCatDocument[0].commentsCount! + "1";
      // } else {          Strings.selectedProDocument[0].commentsCount =
      //       Strings.selectedProDocument[0].commentsCount! + "1";
      // }
      // tagedUsers = [];
      // tagedUsersId = [];
      // tagedCats = [];
      // tagedCatsId = [];

      setState(() {
        _msgcontroller.text = '';
        typing = false;
        // if (showscroll != true) {
        // _scrollController.animateTo(
        //   _scrollController.position.maxScrollExtent,
        //   curve: Curves.fastOutSlowIn,
        //   duration: const Duration(seconds: 1),
        // );
        msgField.unfocus();
        print("Changing variable status");

        CatData.clear();
        UserData.clear();
        tagedCats.clear();
        tagedCatsId.clear();
        tagedUsers.clear();
        tagedUsersId.clear();

        // getReplies();
      });

      // } else {
      //   showscroll = false;
      // }
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
  final status = await Permission.microphone.request();
  if (status.isPermanentlyDenied) {
    AppUtils.showToastError(
        "Please enable Microphone from App permission Settings");
  }
}
