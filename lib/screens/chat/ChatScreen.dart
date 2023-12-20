import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mta/models/Chat/ChatMessageRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/chat/ChatMedia.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/strings.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:v_chat_mention_controller/v_chat_mention_controller.dart';


import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:path/path.dart' as path;

import '../../utilities/apputilities.dart';
import '../../utilities/drawables.dart';



var dio = Dio();




String? filepath;
IO.Socket? _socket;

class ChatScreen extends StatefulWidget {
  static const String routeName = "/chatScreen";
final int groupId;

    ChatScreen({required this.groupId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin 
    {
  var _currDoc;

  TextEditingController _msgcontroller = TextEditingController();
 final ItemScrollController itemScrollController = ItemScrollController();
final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();  FocusNode msgField = new FocusNode();
List<ChatMessageRes> chatList = [];
  String? basePath;

  String temp  = "";


  //mention users
final controller = VChatTextMentionController(
    debounce: 500,
    ///set custom style
    mentionStyle: const TextStyle(
      color: Colors.deepPurple,
      fontWeight: FontWeight.w800,
    ),
  );
  String parsedText = "";
  final logs = <String>[];
  final _fakeUsersDataServer = List.generate(100, (index) => "user$index");
  final users = <String>[];
  bool _isSearchCanView = false;


  List<InlineSpan> customizeText(String text)
  {
        // final regex = RegExp('\'.+\'');
        // final target = regex.stringMatch(testString)!;
      List<InlineSpan> spans;

        final regex = RegExp(r'\$\$(.*?)\$\$');
        const placeholder = '{@}';
        final target = regex.stringMatch(text) ?? "";
        final updatedString = text.replaceAll(regex, placeholder);
        final tokens = updatedString.split(RegExp(' '));

        print("tokenssss $tokens");
        spans = tokens
        .map((e) => e == placeholder
        ? TextSpan(text: target + ' ', style: const TextStyle(color: Colors.blue))
        : TextSpan(text: e + ' '))
        .toList();

        return spans;
  }


  @override
  void initState() {
    super.initState();
    findPath();
    print("groupId _> ${widget.groupId}");
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'query': {
            'token': Strings.authToken,
            'group_id' : widget.groupId
      }
    });
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      joinGroup();
    });

    
    controller.onSearch = (str) async 
    {
      users.clear();
      if (str != null) 
      {
        //  print("search by $str");
        _isSearchCanView = true;
        if (str.isEmpty) {
          users.addAll(_fakeUsersDataServer);
        }
        //send request
        for (var element in _fakeUsersDataServer) {
          if (element.startsWith(str)) {
            users.add(element);
          }
        }
      } else {
        //stop request
        _isSearchCanView = false;
      }
      setState(() {});
    };
  }


  findPath() async
  {
    basePath = await AppUtils.findFilePath();
  }

  joinGroup()
  {
    _socket?.emit(
          'join-group',
          json.encode({
            "group_id": widget.groupId,
          } 
          ));

          getMessages();
  }

  getMessages()
  {
    print("getting messages");
      _socket?.on("group-messages", (_data) {
        print("data $_data");
        chatList.clear();
        setState(() 
        {
           for (var item in _data) {
            chatList.add(ChatMessageRes.fromJson(item));
          }
          print("qwweertt $chatList");
        });
    });
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

  updateDownloadStatus(msgId) {
    final api = Provider.of<ApiService>(context, listen: false);
    api.updateDownloadStatus(msgId,1).then((response) {
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


  updateChat()
  {
     _socket?.emitWithAck(
          'create-message',
          json.encode({
            "message": controller.text,
            "group_id": widget.groupId,
            "user_id": Strings.userID,
            "parent_message_id":""
          }),ack: (_data){
            print("dataaa ${_data}");
          });
         
          FocusManager.instance.primaryFocus?.unfocus();
          controller.clear();
  }

  @override
  void dispose() {
      super.dispose();
    _socket?.disconnect();
    _socket?.dispose();
  }


upload(grpId) async {



FilePickerResult? result = await FilePicker.platform.pickFiles(
  allowMultiple: true,
  type: FileType.custom,
  allowedExtensions: ['jpg', 'pdf', 'doc'],
);
if(result != null) 
{
    List<MultipartFile> files = result.paths.map((path) => 
        MultipartFile.fromFileSync(
            path!, 
            filename: getFileName(path),
            // contentType: MediaType(
            //     lookupMimeType(getFileName(path))?.split('/')[0],
            //     lookupMimeType(getFileName(path))?.split('/')[1],
            // ),
      )
    ).toList();  
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': Strings.userID, 
        'group_id': grpId, 
        'groupFile': files,
      });
      int totalLength = 0;
  for (MultipartFile file in files) {
    int content = await file.length;
    totalLength += content;
  }

  print("print totla ${(totalLength/1024)}");

      var totalSize = totalLength/1024;

  //var response = await dio.post('https://demo.emeetify.com:81/mta/chat/createMessage', data: formData); 
  // check response status code
 if(totalSize <= 25600)
 {
print("insideeee");
try{
   var  myUrl = 'https://demo.emeetify.com:81/mta/chat/createMessage';
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
      if (response.statusCode == 200) 
      {

            print("checkkk inside");
            // _socket?.disconnect();
            // _socket?.dispose();
            // _socket?.destroy();

            
                joinGroup();

            AppUtils.dismissprogress();
          
      } else if (response.statusCode == 404) {
            AppUtils.dismissprogress();
            AppUtils.showToastError("Sorry, File  not Found !");
          } else {
            AppUtils.dismissprogress();
          }
}
catch (e) {
      AppUtils.dismissprogress();
        print(e);
    }

 }
 else
 {
  _showFileSizeWarning();
 }


 
} else {
   // User canceled the picker
}
}
String getFileName(String _path){
    return path.basename(_path); 
}




  void _downloadfile(serverURL, filename) async {
    
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
        var downloadedFile = await download2(dio,serverURL,'$basePath/$fileName');

   // var downloadedFile = await downloadFile(serverURL, fileName, path!);

                    joinGroup();

    
    AppUtils.openFile(downloadedFile);
  }

  


Future download2(Dio dio, String url, String savePath) async 
  {
    try {
          var  myUrl = Strings.uatImageUrl + url;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
          appBar: AppBar(
    iconTheme: IconThemeData(color: Colors.black),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0))),
    elevation: 8,
    title: InkWell(
      onTap: (){
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatMedia(groupId: widget.groupId,),
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
            style: Drawables.adddoccontentstyle(Colors.black, 16.0, FontWeight.bold),
          ),
        ),
      ),
    ),
  ),
          backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    
      
                    Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child:    ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              return Card(
              child: 
              ListTile(title: (chatList[index].files == null)? Text.rich(TextSpan(children: customizeText(chatList[index].message ?? ""))):InkWell(
                onTap: ()
                {
                  updateDownloadStatus(chatList[index].messageId);

                  if(chatList[index].isDownloaded == 0)
                  {
                      _downloadfile(chatList[index].files!,chatList[index].fileName);
                  }
                  else
                  {
                   AppUtils.openFile(basePath!+"/"+ chatList[index].fileName!+AppUtils.getFileExtension(chatList[index].files!));
                  }
                },
                child: 
                //Image.asset(getFileExt(chatList[index].files!),height: 100,),
                SizedBox(
                  width: 200,
                  height: 200,
                  child:                   
Stack(children: [Center(child: Image.asset(getFileExt(chatList[index].files!),height: 100,fit: BoxFit.cover,)),
                if(chatList[index].isDownloaded == 0)Center(child: Icon(Icons.download,size: 50,color: Colors.black,),)]))
                  
                  
                  ),
              subtitle: Text(chatList[index].userName ?? "qwerr",style: TextStyle(color: Colors.grey,fontSize: 12),),),
              );
            }
            ),
        
                      
                      )
        
                  ],
                )),
            SizedBox(height: 10),
            
            // Stack(children: [
            //   Align(
            //     alignment: Alignment.topLeft,
            //     child: Container(
            //       width: MediaQuery.of(context).size.width * 0.85,
            //       child: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Container(
            //           padding: EdgeInsets.only(left: 20),
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.all(Radius.circular(50)),
            //               color: Colors.white),
            //           child: Row(
            //             children: [
            //               InkWell(
            //                   onTap: () 
            //                   {
            //                   //  _socket?.disconnect();
            //                     upload(widget.groupId);
            //                    // Navigator.pop(context);
            //                   },
            //                   child: Icon(Icons.attach_file)),
            //               SizedBox(
            //                 width: MediaQuery.of(context).size.width * 0.02,
            //               ),
            //               Container(
            //                 width: MediaQuery.of(context).size.width * 0.6,
            //                 child: TextField(
            //                   controller: _msgcontroller,
            //                   onChanged: (value) {
                                
            //                   },
            //                   style: TextStyle(color: Colors.black),
            //                   focusNode: msgField,
                            
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            //   Positioned(
            //     right: 15,
            //     bottom: 12,
            //     child: Container(
            //       width: 40,
            //       height: 40,
            //       decoration: BoxDecoration(
            //           color: Color(0xFF0061b0),
            //           borderRadius:
            //               new BorderRadius.all(new Radius.circular(50.0))),
            //       child: GestureDetector(
            //         onLongPress: () {
            //           setState(() {
                      
            //           });
            //         },
            //         onLongPressEnd: (details) async {
            //           // AppUtils.showToast(details.toString());
            //           setState(() async {
                      
            //           });
            //         },
            //         onTap: () {
            //           updateChat();
            //         },
            //         child: Icon(
            //                 Icons.send,
            //                 color: Colors.white,
            //                 size: 18,
            //               ),
            //       ),
            //     ),
            //   ),
            // ]),

            Container(
              height: 0,
              color: Colors.white,
                  child: 
                  ListView.builder(
                    itemBuilder: (context, index) => ListTile(
                      title: ParsedText(
                        text: logs[index],
                        style: const TextStyle(color: Colors.black87),
                        parse: <MatchText>[
                          MatchText(
                            pattern: r"\[(@[^:]+):([^\]]+)\]",
                            style: const TextStyle(
                              color: Colors.indigo,
                            ),
                            renderWidget: ({required pattern, required text}) {
                              return Text(text);
                            },
                            // you must return a map with two keys
                            // [display] - the text you want to show to the user
                            // [value] - the value underneath it
                            renderText: (
                                {required String str, required String pattern}) {
                              final map = <String, String>{};
                              final RegExp customRegExp =
                                  RegExp(r"\[(@[^:]+):([^\]]+)\]");
                              final match = customRegExp.firstMatch(str);
                              map['display'] = match!.group(1)!;
                              return map;
                            },
                            onTap: (url) 
                            {
                              final customRegExp = RegExp(r"\[(@[^:]+):([^\]]+)\]");
                              final match = customRegExp.firstMatch(url)!;

                              print("ontapped $url");
                              final snackBar = SnackBar(
                                content: Text(
                                    'id is ${match.group(2)} name is ${match.group(1)}'),
                                duration: const Duration(seconds: 7),
                              );
        
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            },
                          ),
                        ],
                      ),
                    ),
                    itemCount: logs.length,
                  ),
                ),
                
                Column(
                  children: [
                    Visibility(
                      visible: _isSearchCanView,
                      child: Container(
                        color: Colors.white,
                        height: 200,
                        child: ListView(
                          shrinkWrap: true,
                          children: users
                              .map(
                                (e) => ListTile(
                                  onTap: () {
                                    controller.addMention(
                                      MentionData(
                                        id: "id-$e",
                                        display: "##$e##",
                                      ),
                                    );
                                  },
                                  title: Text(e),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 36,),
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(8),
                      color: Colors.white,
                      child: Row(
                        children: [
                            InkWell(
                              onTap: () 
                              {
                              //  _socket?.disconnect();
                                upload(widget.groupId);
                               // Navigator.pop(context);
                              },
                              child: Icon(Icons.attach_file)),
                              SizedBox(width: 8,),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              onChanged: (val){
                                temp = val;
                              },

                            
                            ),
                          ),
                          SizedBox(width: 8,),
                          FloatingActionButton(
                            backgroundColor: Colors.blue,
                            onPressed: () {

                              updateChat();
                              print("klll ${controller.text}");
                            },
                            child: const Text("Send",style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                    ),      
                    ])
          ],
        ),
      ),
    );


    
  }

Future<bool> _showFileSizeWarning() async 
  {
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

// void getPermission() async 
// {
//   var status = await Permission.microphone.status;
//   if (status.isDenied) {
//     await Permission.microphone.request();
//   } else if (status.isPermanentlyDenied) {
//     AppUtils.showToastError(
//         "Please enable Microphone from App permission Settings");
//   } else {
//     await Permission.microphone.request();
//   }
// }
