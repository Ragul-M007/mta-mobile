import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/FectchProjectDocReq.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

class ViewDocScreen extends StatelessWidget {
  const ViewDocScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: Scaffold(
          appBar: appbar("Documents"),
          backgroundColor: Colors.grey[300],
          body: ViewDocContent(),
        ));
  }
}

class ViewDocContent extends StatefulWidget {
  ViewDocContent({Key? key}) : super(key: key);

  @override
  _ViewDocContentState createState() => _ViewDocContentState();
}

class _ViewDocContentState extends State<ViewDocContent> {
  List<ProjectDocData> _docsList = [];
  List<FetchCategoryDoc> _categorydocsList = [];

  // List<ProjectDocData> _searchProLists = [];
  // List<FetchCategoryDoc> _searchCatsLists = [];
  var _searchList = [];
  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();
  String? filepath;
  var dio = Dio();

  String _errText = "";

  void initState() {
    super.initState();
    getPermission();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getDocs());
  }

  //get storage permission
  void getPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  webcheck() {
    FlutterWebBrowser.openWebPage(
      url: "https:google.com/",
      customTabsOptions: const CustomTabsOptions(
        colorScheme: CustomTabsColorScheme.dark,
        toolbarColor: Colors.deepPurple,
        secondaryToolbarColor: Colors.green,
        navigationBarColor: Colors.amber,
        shareState: CustomTabsShareState.on,
        instantAppsEnabled: true,
        showTitle: true,
        urlBarHidingEnabled: true,
      ),
      safariVCOptions: const SafariViewControllerOptions(
        barCollapsingEnabled: true,
        preferredBarTintColor: Colors.green,
        preferredControlTintColor: Colors.amber,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        modalPresentationCapturesStatusBarAppearance: true,
      ),
    );
  }

  void _downloadfile(serverURL,filename) async {
    String? path;
    if (Platform.isAndroid) {
      path = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      print("ios");
      var vpath = await getApplicationDocumentsDirectory();
      String pathStr = vpath.toString();
      if (pathStr != null && pathStr.length >= 5) 
      {
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
    var fileName = nospace+extn;
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
      print(myUrl);
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/adddoc');
              },
              child: Image.asset("assets/icons/addDoc.png",
                  width: 120.0, height: 120.0)),
          Text(
            "Add Documents",
            style: Drawables.adddoccontentstyle(
                Colors.black, 20.0, FontWeight.w600),
          ),
          Text(
            Strings.category == true
                ? Strings.selectedProject[0].projectName! +
                    " >> " +
                    Strings.selectedCategory[0].categoryName!
                : Strings.selectedProject[0].projectName!,
            style: Drawables.adddoccontentstyle(
                Colors.black45, 15.0, FontWeight.w400),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Container(
              //  padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFFeceeef),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Material(
                  color: const Color(0xFFeceeef),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          focusNode: searchField,
                          controller: _searchFieldController,
                          decoration: InputDecoration.collapsed(
                            hintText: ' Search',
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                // _searchCatsLists = [];
                                // _searchProLists = [];
                                _searchList = [];
                              });
                              return;
                            }
                            // _searchCatsLists = [];
                            // _searchProLists = [];
                            _searchList = [];
                            if (Strings.category == true) {
                              _categorydocsList.forEach((detail) {
                                if (detail.fileName!
                                    .toLowerCase()
                                    .startsWith(value.toLowerCase()))
                                  //_searchCatsLists.add(detail);
                                  _searchList.add(detail);
                              });
                            } else {
                              _docsList.forEach((detail) {
                                if (detail.fileName!
                                    .toLowerCase()
                                    .startsWith(value.toLowerCase()))
                                  // _searchProLists.add(detail);
                                  _searchList.add(detail);
                              });
                            }

                            setState(() {});
                          },
                        ),
                      ),
                      InkWell(
                        child: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        onTap: () {
                          print("search");
                          webcheck();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          _searchList.length != 0
              ? GridView.builder(
                  shrinkWrap: true,
                  itemCount: _searchList.length,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 10.0, right: 5.0),
                      child: new Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: new GridTile(
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _downloadfile(_searchList[index].file,_searchList[index].fileName);
                                      },
                                      child: Stack(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(top: 0),
                                            child: Image.asset(
                                                getFileExt(
                                                    _searchList[index].file),
                                                width: 70.0,
                                                height: 70.0),
                                          ),
                                          Positioned(
                                            top: 2,
                                            left: 10,
                                            child: Container(
                                                child: Icon(
                                              Icons.download_rounded,
                                              size: 20.0,
                                            )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 45.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showMyDialogProject(
                                            context,
                                            _searchList[index].fileName,
                                            _searchList[index].description,
                                            _searchList[index].createdAt,
                                            _searchList[index].name);
                                      },
                                      child: Container(
                                          child: Icon(
                                        Icons.info_outlined,
                                        size: 20.0,
                                      )),
                                    )
                                  ],
                                )),
                          ),
                          footer: Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      _searchList[index].fileName,
                                      style: Drawables.adddoccontentstyle(
                                          Colors.black87,
                                          14.0,
                                          FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(height: 7.0),
                                  GestureDetector(
                                    onTap: () {
                                      print("comments");
                                      Strings.selectedDocsIndex = index;
                                      Strings.selectedCatDocument = [];
                                      Strings.selectedCatDocument
                                          .add(_searchList[index]);
                                      getUserCats();
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 10.0),
                                        Image.asset("assets/icons/Comments.png",
                                            width: 15.0, height: 15.0),
                                        SizedBox(width: 5),
                                        Text(
                                          _searchList[index]
                                                  .commentsCount
                                                  .toString() +
                                              " Comments",
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                    );
                  },
                )
              : _searchFieldController.text != ""
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "No results found",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  : Strings.category == true
                      ? _categorydocsList.length > 0
                          ? GridView.builder(
                              shrinkWrap: true,
                              itemCount: _categorydocsList.length,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      top: 10.0,
                                      bottom: 10.0,
                                      right: 5.0),
                                  child: new Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: new GridTile(
                                      child: Container(
                                        child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 15, 10, 0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    _downloadfile(
                                                        _categorydocsList[index]
                                                            .file,_categorydocsList[index].fileName);
                                                  },
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 0),
                                                        child: Image.asset(
                                                            getFileExt(
                                                                _categorydocsList[
                                                                        index]
                                                                    .file!),
                                                            width: 70.0,
                                                            height: 70.0),
                                                      ),
                                                      Positioned(
                                                        top: 2,
                                                        left: 10,
                                                        child: Container(
                                                            child: Icon(
                                                          Icons
                                                              .download_rounded,
                                                          size: 20.0,
                                                        )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 45.0,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    _showMyDialogProject(
                                                        context,
                                                        _categorydocsList[index]
                                                            .fileName,
                                                        _categorydocsList[index]
                                                            .description,
                                                        _categorydocsList[index]
                                                            .createdAt,
                                                        _categorydocsList[index]
                                                            .name);
                                                  },
                                                  child: Container(
                                                      child: Icon(
                                                    Icons.info_outlined,
                                                    size: 20.0,
                                                  )),
                                                )
                                              ],
                                            )),
                                      ),
                                      footer: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 0, 0, 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  _categorydocsList[index]
                                                      .fileName!,
                                                  style: Drawables
                                                      .adddoccontentstyle(
                                                          Colors.black87,
                                                          14.0,
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              SizedBox(height: 7.0),
                                              GestureDetector(
                                                onTap: () {
                                                  print("Comments clicked");
                                                  Strings.selectedDocsIndex =
                                                      index;
                                                  Strings.selectedCatDocument =
                                                      [];
                                                  Strings.selectedCatDocument
                                                      .add(_categorydocsList[
                                                          index]);

                                                   getUserCats();
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    SizedBox(width: 10.0),
                                                    Image.asset(
                                                        "assets/icons/Comments.png",
                                                        width: 15.0,
                                                        height: 15.0),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      _categorydocsList[index]
                                                              .commentsCount
                                                              .toString() +
                                                          " Comments",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              child: Padding(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _errText,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                            ))
                      : _docsList.length > 0
                          ? GridView.builder(
                              shrinkWrap: true,
                              itemCount: _docsList.length,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      top: 10.0,
                                      bottom: 10.0,
                                      right: 5.0),
                                  child: new Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: new GridTile(
                                      child: Container(
                                        child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 15, 10, 0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    _downloadfile(
                                                        _docsList[index].file,_docsList[index].fileName);
                                                  },
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 0),
                                                        child: Image.asset(
                                                            getFileExt(
                                                                _docsList[index]
                                                                    .file!),
                                                            width: 70.0,
                                                            height: 70.0),
                                                      ),
                                                      Positioned(
                                                        top: 2,
                                                        left: 10,
                                                        child: Container(
                                                            child: Icon(
                                                          Icons
                                                              .download_rounded,
                                                          size: 20.0,
                                                        )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 45.0,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    _showMyDialogProject(
                                                        context,
                                                        _docsList[index]
                                                            .fileName,
                                                        _docsList[index]
                                                            .description,
                                                        _docsList[index]
                                                            .createdAt,
                                                        _docsList[index].name);
                                                  },
                                                  child: Container(
                                                      child: Icon(
                                                    Icons.info_outlined,
                                                    size: 20.0,
                                                  )),
                                                )
                                              ],
                                            )),
                                      ),
                                      footer: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 0, 0, 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  _docsList[index].fileName!,
                                                  style: Drawables
                                                      .adddoccontentstyle(
                                                          Colors.black87,
                                                          14.0,
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              SizedBox(height: 7.0),
                                              GestureDetector(
                                                onTap: () {
                                                  print("Comments final");
                                                  Strings.selectedDocsIndex =
                                                      index;
                                                  Strings.selectedProDocument =
                                                      [];
                                                  Strings.selectedProDocument
                                                      .add(_docsList[index]);
                                                  getUserCats();
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    SizedBox(width: 10.0),
                                                    Image.asset(
                                                        "assets/icons/Comments.png",
                                                        width: 15.0,
                                                        height: 15.0),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      _docsList[index]
                                                              .commentsCount
                                                              .toString() +
                                                          " Comments",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              child: Padding(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _errText,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                            ))
        ],
      ),
    );
  }

  getDocs() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);

    if (Strings.category == true) {
      print("Category");
      AppUtils.getIntPreferences('userId').then((value) {
        api
            .getCategoryDoc(Strings.selectedCategory[0].categoryId!,
                Strings.selectedProject[0].projectId!, value)
            .then((response) {
          AppUtils.dismissprogress();
          print('DocsResponse status ${response.toJson()}');
          if (response.status!) {
            setState(() {
              _categorydocsList = response.data!;
              print("docname ${_categorydocsList[0].name}");
            });
          } else {
            setState(() {
              _errText = "No Documents found !";
            });
            // if (response.message != null) {
            //   AppUtils.showToastError(response.message);
            // }
            // else {
            //   AppUtils.showToastError("No Documents found !");
            // }
          }
        }).catchError((onError) {
          AppUtils.dismissprogress();
          print(onError.toString());
        });
      });
    } else {
      AppUtils.getIntPreferences('userId').then((value) {
        FetchProjectDocReq fetchProjectDocReq = FetchProjectDocReq();
        fetchProjectDocReq.projectId = Strings.selectedProject[0].projectId;
        api
            .getProjectDoc(fetchProjectDocReq.projectId!, value)
            .then((response) {
          AppUtils.dismissprogress();
          print('DocsResponse status ${response.toJson()}');
          if (response.status!) {
            setState(() {
              _docsList = response.data!;
            });
          } else {
            setState(() {
              _errText = "No Documents found !";
              //  _errText = response.message;
            });
            // if (response.message != null) {
            //   AppUtils.showToastError(response.message);
            // }
            // else {
            //   AppUtils.showToastError("No Documents found !");
            // }
          }
        }).catchError((onError) {
          AppUtils.dismissprogress();
          print(onError.toString());
        });
      });
    }
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
      return ".doc";
    }
  }

  Future<void> _showMyDialogProject(context, title, desc, created, name) async {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        new Icon(Icons.close, size: 22.0, color: Colors.black)
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Created at : " + getForamtDate(created),
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0061b0),
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Description : " + desc,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Uploaded By : " + name,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  String getForamtDate(String createdAt) {
    DateTime formatDate = DateTime.parse(createdAt);
    return DateFormat("dd/MM/yyyy").format(formatDate);
  }

  getUserCats() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchUsers(Strings.selectedProject[0].projectId!).then((response) {
      if (response.status!) 
      {
        setState(() {
          Strings.users = response.data!;
        });
        final api = Provider.of<ApiService>(context, listen: false);
        print("PRo id ${Strings.selectedProject[0].projectId!}");
        api.fetchCats(Strings.selectedProject[0].projectId!).then((response) {
          AppUtils.dismissprogress();
          if (response.status!) 
          {
            setState(() {
              Strings.categories = response.data!;
              Navigator.pushNamed(context, '/comments');
            });
          } else {
            Navigator.pushNamed(context, '/comments');
            print('No categories');
          }
        }).catchError((onError) {
          AppUtils.dismissprogress();
          print("Catched $onError");
        });
      } else 
      {
        Navigator.pushNamed(context, '/comments');
        AppUtils.dismissprogress();
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
}
