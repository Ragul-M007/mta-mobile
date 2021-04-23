import 'package:flutter/material.dart';
import 'package:mta/models/FectchProjectDocReq.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/FetchCategoryDocRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

class ViewDocScreen extends StatelessWidget {
  const ViewDocScreen({Key key}) : super(key: key);

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
  ViewDocContent({Key key}) : super(key: key);

  @override
  _ViewDocContentState createState() => _ViewDocContentState();
}

class _ViewDocContentState extends State<ViewDocContent> {
  List<ProjectDocData> _docsList = [];
  List<FetchCategoryDoc> _categorydocsList = [];
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getDocs());
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
                ? Strings.selectedProject[0].projectName +
                    " >> " +
                    Strings.selectedCategory[0].categoryName
                : Strings.selectedProject[0].projectName,
            style: Drawables.adddoccontentstyle(
                Colors.black45, 15.0, FontWeight.w400),
          ),
          Strings.category == true
              ? GridView.builder(
                  shrinkWrap: true,
                  itemCount: _categorydocsList.length,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    return _categorydocsList != null
                        ? Padding(
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
                                      padding:
                                          EdgeInsets.fromLTRB(10, 15, 10, 0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 0),
                                            child: Image.asset(
                                                "assets/icons/doc.png",
                                                width: 70.0,
                                                height: 70.0),
                                          ),
                                          SizedBox(
                                            width: 45.0,
                                          ),
                                          Container(
                                              child: Icon(
                                            Icons.info_outlined,
                                            size: 20.0,
                                          ))
                                        ],
                                      )),
                                ),
                                footer: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            _categorydocsList[index].fileName,
                                            style: Drawables.adddoccontentstyle(
                                                Colors.black87,
                                                14.0,
                                                FontWeight.w500),
                                          ),
                                        ),
                                        SizedBox(height: 7.0),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/comments');
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
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
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
                          )
                        : SizedBox();
                  },
                )
              : GridView.builder(
                  shrinkWrap: true,
                  itemCount: _docsList.length,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    return _docsList != null
                        ? Padding(
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
                                      padding:
                                          EdgeInsets.fromLTRB(10, 15, 10, 0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 0),
                                            child: Image.asset(
                                                "assets/icons/doc.png",
                                                width: 70.0,
                                                height: 70.0),
                                          ),
                                          SizedBox(
                                            width: 45.0,
                                          ),
                                          Container(
                                              child: Icon(
                                            Icons.info_outlined,
                                            size: 20.0,
                                          ))
                                        ],
                                      )),
                                ),
                                footer: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            _docsList[index].fileName,
                                            style: Drawables.adddoccontentstyle(
                                                Colors.black87,
                                                14.0,
                                                FontWeight.w500),
                                          ),
                                        ),
                                        SizedBox(height: 7.0),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/comments');
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
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
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
                          )
                        : SizedBox();
                  },
                )
        ],
      ),
    );
  }

  getDocs() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);

    if (Strings.category == true) {
      api
          .getCategoryDoc(Strings.selectedCategory[0].categoryId,
              Strings.selectedProject[0].projectId)
          .then((response) {
        AppUtils.dismissprogress();
        print('DocsResponse status ${response.toJson()}');
        if (response.status) {
          setState(() {
            _categorydocsList = response.data;
          });
        } else {
          print('error');
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        print(onError.toString());
      });
    } else {
      FetchProjectDocReq fetchProjectDocReq = FetchProjectDocReq();
      fetchProjectDocReq.projectId = Strings.selectedProject[0].projectId;
      api.getProjectDoc(fetchProjectDocReq.projectId).then((response) {
        AppUtils.dismissprogress();
        print('DocsResponse status ${response.toJson()}');
        if (response.status) {
          setState(() {
            _docsList = response.data;
          });
        } else {
          print('error');
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        print(onError.toString());
      });
    }
  }
}
