import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:mta/models/Chat/ChatMessageRes.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/chat/ChatMedia.dart';
import 'package:mta/utilities/strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:path/path.dart' as path;

import '../../utilities/apputilities.dart';
import '../../utilities/drawables.dart';
import '../MentionFiles/flutter_mentions.dart';

var dio = Dio();

String? filepath;
IO.Socket? _socket;

class ChatScreen extends StatefulWidget {
  static const String routeName = "/chatScreen";
  final int groupId;
    final int teamId;


  ChatScreen({required this.groupId,required this.teamId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin,WidgetsBindingObserver {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  FocusNode msgField = new FocusNode();
  List<ChatMessageRes> chatList = [];
  List<Map<String, dynamic>> userList = [];
  var typing = false;
  var showtoastinfo = false;
  var startRecording = false;
  var isPlaying = false;
  var playingIndex;
  int audioLength = 0;
  int audioCurrentlenth = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache();
  Timer? _timer;
final ScrollController _controller = ScrollController();

  String? basePath;

  String temp = "";
  String recordingPath = "";

  
  String parsedText = "";
  final logs = <String>[];
  final _fakeUsersDataServer = List.generate(100, (index) => "user$index");
  final users = <String>[];
  bool _isSearchCanView = false;
  List<GroupChatUsersData> chatUsers = [];
  final _audioRecorder = AudioRecorder();

  List<InlineSpan> customizeText(String text) {
    // final regex = RegExp('\'.+\'');
    // final target = regex.stringMatch(testString)!;
    List<InlineSpan> spans = [];

    final regex = RegExp(r'##&&%(.*?)##&&%');
    const placeholder = '{@}';

    Iterable<Match> matches = regex.allMatches(text);
    List<String> target = [];

    for (Match match in matches) {
      // match.group(1) contains the content inside the ##&&% sequence
      print('Content: ${match.group(1)}');
      target.add(match.group(1) ?? "");
    }

    // final target = regex.allMatches(text);
    final updatedString = text.replaceAll(regex, placeholder);
    final tokens = updatedString.split(RegExp(' '));

    print("tokenssss $tokens");

    var placeHolderindex = 0;
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == placeholder) {
        print("iiu $placeHolderindex klklkl ${target[placeHolderindex]}");
        spans.add(TextSpan(
            text: target[placeHolderindex] + ' ',
            style: const TextStyle(color: Colors.blue)));
        placeHolderindex = placeHolderindex + 1;
      } else {
        print("adding ${tokens[i]}");
        spans.add(TextSpan(text: tokens[i] + ' '));
      }
    }

    // spans = tokens.map((e) => e == placeholder
    // ? TextSpan(text: target[target.indexOf(e)+1] + ' ', style: const TextStyle(color: Colors.blue))
    // : TextSpan(text: e + ' '))
    // .toList();

    return spans;
  }

  void _scrollDown() {
  _controller.animateTo(
    _controller.position.maxScrollExtent - 30,
    duration: Duration(seconds: 2),
    curve: Curves.fastOutSlowIn,
  );
}

 @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("App Lifecycle State: $state");
    if(AppLifecycleState.inactive == state)
    {
      stopAudio();
    }
    // Handle lifecycle state changes here
  }

  playAudio(url) async {
    // var dir = await ExtStorage.getExternalStoragePublicDirectory(
    //     ExtStorage.DIRECTORY_DOWNLOADS);
    // String url = dir + "/MTARecordedAudio.wav";
    print(Strings.uatImageUrl + url);
    audioPlayer.onDurationChanged.listen((Duration d) 
    {
      int seconds = d.inSeconds;
      print('Max duration: $d');
      setState(() {
        audioLength = seconds;
      });
    });
      //  await audioPlayer.play(UrlSource("/data/user/0/com.skein.mta/cache/16-01-24-07-07-358508816020182323942.m4a"), volume: 5);

   await audioPlayer.play(UrlSource(Strings.uatImageUrl + url), volume: 5);
    audioPlayer.onPositionChanged.listen((Duration p) 
    {
      int seconds = p.inSeconds;
      print('curr duration: $p');
      setState(() {
        audioCurrentlenth = seconds;
      });
    });


    audioPlayer.onPlayerComplete.listen((event) 
    {
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

  addMentionUsers() {
    userList.clear();
    for (int i = 0; i < chatUsers.length; i++) {
      var user = {
        "id": chatUsers[i].userId.toString(),
        "display": chatUsers[i].userName?.split(' ')[0],
        "full_name": chatUsers[i].userName,
        "photo": Strings.uatImageUrl + (chatUsers[i].userImage ?? "")
      };
      userList.add(user);
    }
  }

  @override
  void initState() {
    super.initState();
    findPath();
    print("groupId _> ${widget.groupId}  ${widget.teamId}");
        WidgetsBinding.instance.addObserver(this);
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'query': {'token': Strings.authToken, 
      'group_id': widget.groupId,
      "group_type":"team",
      "project_id":null,
      "team_id":widget.teamId
      }
    });
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      joinGroup();
      getUsersByGroupId();
    });


     _controller.addListener(() {
    if (_controller.position.atEdge) {
      bool isTop = _controller.position.pixels == 0;
      if (isTop) {
        getMessagesWithPageCount();
        print('At the top');
      } else {
        print('At the bottom');
      }
    }
  });
  
  }

  findPath() async {
    basePath = await AppUtils.findFilePath();
  }

  joinGroup() {
    _socket?.emit(
        'join-group',
        json.encode({
          "group_id": widget.groupId,
        }));

    getMessages();
  }

  getMessages()
  {
    print("getting messages");
    _socket?.on("group-messages", (_data) {
      log("data $_data");
      chatList.clear();
      setState(() {
        for (var item in _data) {
          chatList.add(ChatMessageRes.fromJson(item));
        }
        print("qwweertt $chatList");
        _scrollDown();
      });
    });
  }

  

  Future<void> stopRecord() async {
    await _audioRecorder.stop();
    sendRecordedAudio();
  }

  sendRecordedAudio() 
  {
    print("path $recordingPath");
    List<MultipartFile> audioFile = [
      MultipartFile.fromFileSync(
        "$recordingPath",
        filename: getFileName("$recordingPath"),
      )
    ];
    var formData = FormData.fromMap({
      'parent_message_id':"",
      'user_id': Strings.userID,
      'group_id': widget.groupId,
      'groupFile': audioFile,
    });
    uploadFile(formData);
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

  String getFileExt(String? fileName) 
  {
    print("Filename--> $fileName");
    var file = fileName?.split("/");
    var fileExttemp = file?[file.length - 1];

    var finalSplit = fileExttemp?.split(".");
    var fileExt = finalSplit?[finalSplit.length - 1];

    print("exttt $fileExt");
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

  var uniqueRecordId = Uuid().v1();

  updateDownloadStatus(msgId) 
  {
    final api = Provider.of<ApiService>(context, listen: false);
    api.updateDownloadStatus(msgId, 1).then((response) {
      if (response.status!) {
        // AppUtils.showToastError("update status successfully");
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

  getUsersByGroupId() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.getChatUsers(widget.groupId).then((response) {
      if (response.status!) {
        setState(() {
          chatUsers = response.data!;
          addMentionUsers();
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
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

  recordComments() async {
    var path;
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
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      getPermission();
    } else {
      recordingPath = path + '/' + "${uniqueRecordId}_mta12" + '.m4a';

      print("record bfre $recordingPath");
      _audioRecorder.start(
        const RecordConfig(),
        path: recordingPath,
      );

      // Replace 'your_file.txt' with the actual file name you want to access
    }
  }

  void getPermission() async {
    var status = await Permission.microphone.status;
    print("srtatus $status");
    if (status.isDenied) {
      await Permission.microphone.request();
    } else if (status.isPermanentlyDenied) {
      AppUtils.showToastError(
          "Please enable Microphone from App permission Settings");
    } else {
      await Permission.microphone.request();
    }
  }

  updateChat() 
  {
    _socket?.emitWithAck(
        'create-message',
        json.encode({
          "message": key.currentState!.controller!.markupText,
          "group_id": widget.groupId,
          "user_id": Strings.userID,
          "parent_message_id": ""
        }), ack: (_data) {
      print("dataaa ${_data}");
    });

    FocusManager.instance.primaryFocus?.unfocus();
    key.currentState!.controller!.clear();
  }

  getMessagesWithPageCount() 
  {
    _socket?.emitWithAck(
        'get-message-with-pagecount',
        json.encode({
          "page_no": 2,
          "group_id": widget.groupId,
          
        }), ack: (_data) {
      print("dataaa ${_data}");
    });

    FocusManager.instance.primaryFocus?.unfocus();
    key.currentState!.controller!.clear();
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose called");
    stopAudio();
    WidgetsBinding.instance.removeObserver(this);
    _socket?.disconnect();
    _socket?.dispose();
  }

  upload(grpId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'm4a', 'mp3'],
    );
    if (result != null) {
      List<MultipartFile> files = result.paths
          .map((path) => MultipartFile.fromFileSync(
                path!,
                filename: getFileName(path),
                // contentType: MediaType(
                //     lookupMimeType(getFileName(path))?.split('/')[0],
                //     lookupMimeType(getFileName(path))?.split('/')[1],
                // ),
              ))
          .toList();

      var formData = FormData.fromMap({
        'parent_message_id':"",
        'user_id': Strings.userID,
        'group_id': grpId,
        'groupFile': files,
      });
      int totalLength = 0;
      for (MultipartFile file in files) {
        int content = await file.length;
        totalLength += content;
      }

      print("print totla ${(totalLength / 1024)}");

      var totalSize = totalLength / 1024;

      //var response = await dio.post('https://demo.emeetify.com:81/mta/chat/createMessage', data: formData);
      // check response status code
      if (totalSize <= 25600) {
        print("insideeee");
        uploadFile(formData);
      } else {
        _showFileSizeWarning();
      }
    } else {
      // User canceled the picker
    }
  }

  String getFileName(String _path) {
    return path.basename(_path);
  }

  uploadFile(formData) async {
    try {
      var myUrl = 'https://demo.emeetify.com:81/mta/chat/createMessage';
      var response = await dio.post(
        myUrl,
        data: formData,
        onSendProgress: showUploadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print("response ${response.statusMessage}");

      print("status code ${response.statusCode}");
      if (response.statusCode == 200) {
        joinGroup();
        AppUtils.dismissprogress();
      } else if (response.statusCode == 404) {
        AppUtils.dismissprogress();
        AppUtils.showToastError("Sorry, File  not Found !");
      } else {
        AppUtils.dismissprogress();
      }
    } catch (e) {
      AppUtils.dismissprogress();
      print(e);
    }
  }

  void _downloadfile(serverURL, filename) async 
  {
    // AppUtils.showprogress();
    // AppUtils.showToast('Downloading');

    print("serverURL--> $serverURL");
    //var fileName = filename;//filenames[1];
    var extn = AppUtils.getFileExtension(serverURL);
    var nospace = filename.replaceAll(' ', '');
    var fileName = nospace + extn;
    print("url--> $fileName");
    String fullPath = "$basePath/$fileName";
    print("filepath $fullPath");

    setState(() {
      filepath = fullPath;
    });
    var downloadedFile = await download2(dio, serverURL, '$basePath/$fileName');

    // var downloadedFile = await downloadFile(serverURL, fileName, path!);

    joinGroup();

    AppUtils.openFile(downloadedFile);
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      var myUrl = Strings.uatImageUrl + url;
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

  void showUploadProgress(received, total) {
    if (total != -1) {
      AppUtils.showUploadProgressWithPercent(received / total);
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (_, child) => Portal(child: child!),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(30.0))),
          elevation: 8,
          title: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMedia(
                    groupId: widget.groupId,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 30,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Chat Screen",
                  style: Drawables.adddoccontentstyle(
                      Colors.black, 16.0, FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.grey[300],
        body: Column(children: [
          Container(
          //  height: MediaQuery.of(context).size.height * 0.75,
            child: Expanded(
              child: ListView.builder(
                controller: _controller,
                shrinkWrap: false,
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: (chatList[index].files == null)
                            ? Text.rich(TextSpan(
                                children: customizeText(
                                    chatList[index].message ?? "")))
                            : chatList[index].files!.contains(".m4a")
                                ? Row(
                                    children: [
                                      isPlaying == false
                                          ? GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isPlaying ==
                                                      true) 
                                                      {
                                                    stopAudio();
                                                    _timer = new Timer(
                                                        const Duration(
                                                            milliseconds:
                                                                500),
                                                        () {
                                                      setState(() {
                                                        isPlaying =
                                                            true;
                                                        playingIndex =
                                                            index;
                                                        playAudio(
                                                            chatList[
                                                                    index]
                                                                .files);
                                                      });
                                                    });
                                                  } 
                                                  else 
                                                  {
                                                    isPlaying = true;
                                                    playingIndex =
                                                        index;
                                                    playAudio(
                                                        chatList[index]
                                                            .files);
                                                  }
                                                });
                                              },
                                              child: new Icon(
                                                  Icons.play_arrow,
                                                  size: 28.0),
                                            )
                                          : playingIndex == index
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isPlaying = false;
                                                    });
              
                                                    stopAudio();
                                                  },
                                                  child: new Icon(
                                                      Icons.stop,
                                                      size: 28.0),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (isPlaying ==
                                                          true) {
                                                        stopAudio();
                                                        _timer = new Timer(
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                            () {
                                                          setState(() {
                                                            isPlaying =
                                                                true;
                                                            playingIndex =
                                                                index;
                                                            playAudio(chatList[
                                                                    index]
                                                                .files);
                                                          });
                                                        });
                                                      } else {
                                                        isPlaying =
                                                            true;
                                                        playingIndex =
                                                            index;
                                                        playAudio(
                                                            chatList[
                                                                    index]
                                                                .files);
                                                      }
                                                    });
                                                  },
                                                  child: new Icon(
                                                      Icons.play_arrow,
                                                      size: 28.0),
                                                ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Slider(
                                        value: playingIndex == index
                                            ? audioCurrentlenth
                                                .toDouble()
                                            : 0,
                                        min: 0,
                                        max: playingIndex == index
                                            ? audioLength.toDouble()
                                            : 0,
                                        onChanged: (double value) 
                                        {
                                          setState(() {
                                            playingIndex == index
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
                                      updateDownloadStatus(
                                          chatList[index].messageId);
              
                                      if (chatList[index]
                                              .isDownloaded ==
                                          0) {
                                        _downloadfile(
                                            chatList[index].files!,
                                            chatList[index].fileName);
                                      } else {
                                        AppUtils.openFile(
                                          basePath! +
                                            "/" +
                                            chatList[index].fileName! +
                                            AppUtils.getFileExtension(
                                                chatList[index]
                                                    .files!));
                                      }
                                    },
                                    child:
                                        //Image.asset(getFileExt(chatList[index].files!),height: 100,),
                                        SizedBox(
                                            width: 200,
                                            height: 200,
                                            child: Stack(children: [
                                              Center(
                                                  child: Image.asset(
                                                getFileExt(
                                                    chatList[index]
                                                        .files!),
                                                height: 100,
                                                fit: BoxFit.cover,
                                              )),
                                              if (chatList[index]
                                                      .isDownloaded ==
                                                  0)
                                                Center(
                                                  child: Icon(
                                                    Icons.download,
                                                    size: 50,
                                                    color: Colors.black,
                                                  ),
                                                )
                                            ]))),
                        subtitle: Text(
                          chatList[index].userName ?? "",
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    );
                  }),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      //  _socket?.disconnect();
                      upload(widget.groupId);
                      // Navigator.pop(context);
                    },
                    child: Icon(Icons.attach_file)),
                SizedBox(
                  width: 8,
                ),
                Container(
                                        height: 100,
                                        width: 100,
                  child: Container(
                    child: FlutterMentions(
                      onChanged: (value){
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
                      key: key,
                      suggestionPosition: SuggestionPosition.Top,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(hintText: 'hello'),
                      onMarkupChanged: (kll) {
                        print("mark changeddd $kll");
                      },
                      mentions: [
                        Mention(
                            trigger: '@',
                            style: TextStyle(
                              color: Colors.amber,
                            ),
                            data: userList,
                            matchAll: false,
                            suggestionBuilder: (data) {
                              return Container(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        data['photo'],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(data['full_name']),
                                        Text('@${data['display']}'),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                
                Container(
                  width: startRecording == true ? 60 : 40,
                  height: startRecording == true ? 60 : 40,
                  decoration: BoxDecoration(
                      color: Color(0xFF0061b0),
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(50.0))),
                  child: GestureDetector(
                    onLongPress: () async {
                      var status = await Permission.microphone.status;
                      if (status.isGranted) {
                        startRecording = true;
                        startOrStop();
                        recordComments();
                      } else {
                        AppUtils.showToastError(
                            "Please allow the Microphone Permission");
                        getPermission();
                      }
                    },
                    onLongPressEnd: (details) async {
                      // AppUtils.showToast(details.toString());
                      var status = await Permission.microphone.status;
                      if (status.isGranted) {
                        startRecording = false;
                        startOrStop();
                        stopRecord();
                        // sendAudio();
                      }
                    },
                    onTap: () {
                      if (typing == true) {
  getMessagesWithPageCount() ;

                       // updateChat();
                      } else {
                        setState(() {
                          showtoastinfo = true;
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
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Future<bool> _showFileSizeWarning() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text(
              "File Size is High",
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0061b0),
                  fontWeight: FontWeight.w600),
            ),
            content: Text(
              "Total file size should not be more than 25 MB. Pleasec try again.",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'Okay',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        )) ??
        false;
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
