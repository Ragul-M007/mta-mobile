import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

import '../../models/FetchCategoryUsersRes.dart';
import '../../models/FetchMapedUsersRes.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: appbar("Project Details"),
        body: WillPopScope(
          child: CategoriesContent(),
          onWillPop: () {
            if (Strings.fromProjects == true) {
              Navigator.pushNamed(context, '/projects');
            } else {
              Navigator.pushNamed(context, '/dashboard');
            }
            throw 'Screen Change';
          },
        ),
      ),
    );
  }
}

class CategoriesContent extends StatefulWidget {
  static const String routeName = "/categories";

  @override
  _CategoriesContentState createState() => _CategoriesContentState();
}

class _CategoriesContentState extends State<CategoriesContent> {
  List<FectchCatsData> _catsList = [];
  List<CategoryUsersData> _catUsersList = [];

  List<FetchMapedUsersData>? users;
  String _errText = "";
  void initState() {
    super.initState();
    getUserCats();
    WidgetsBinding.instance.addPostFrameCallback((_) => getCategories());
  }

  showLoading(BuildContext context) {
    showDialog<void>(
      barrierColor: Colors.white.withOpacity(0.4),
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor:
              Colors.white, // can change this to your prefered color
          children: <Widget>[
            Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Text(
                "Please wait! While the team members details are being loading")
          ],
        );
      },
    );
  }

  getUserCats() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchUsers(Strings.selectedProject[0].projectId!).then((response) {
      if (response.status!) {
        setState(() {
          Strings.users = response.data!;
          users = response.data!;
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  getAssignedUsers(catID) {
    _catUsersList = [];
    final api = Provider.of<ApiService>(context, listen: false);
    api
        .getCatUsers(Strings.selectedProject[0].projectId!, catID)
        .then((response) {
      if (response.status!) {
        setState(() {
          _catUsersList = response.data!;
        });
        Navigator.pop(context);
        showCategoryUsersDialog();
      } else {
        AppUtils.showToastError(response.message ?? "Unknown Error");
        Navigator.pop(context);
        print('error');
      }
    }).catchError((onError) {
      Navigator.pop(context);
      AppUtils.showToastError(onError.toString());
    });
  }

  Future<void> _showMyDialogProject() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        new Icon(Icons.close, size: 22.0, color: Colors.black)
                      ]),
                      Text(
                        "Assigned Users",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 1,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ListView.builder(
                          itemCount: users?.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Card(
                                  color: Color.fromRGBO(230, 230, 230, 1),
                                  child: ListTile(
                                    title: Text(
                                      users?[index].name ?? "",
                                    ),
                                    subtitle: Text(users?[index].prof ?? ""),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  )),
            );
          }),
        );
      },
    );
  }

  Future<void> showCategoryUsersDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            print("checkk ${jsonEncode(_catUsersList)}");
            return SingleChildScrollView(
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        new Icon(Icons.close, size: 22.0, color: Colors.black)
                      ]),
                      Text(
                        "Assigned Users",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 1,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: _catUsersList.length != 0
                            ? ListView.builder(
                                itemCount: _catUsersList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Card(
                                        color: Color.fromRGBO(230, 230, 230, 1),
                                        child: ListTile(
                                          title: Text(
                                            _catUsersList[index].name ?? "",
                                          ),
                                          subtitle: Text(
                                              _catUsersList[index].prof ?? ""),
                                          onTap: () {},
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Center(
                                child: Text("No assigned users found",
                                    style: TextStyle(color: Colors.red))),
                      ),
                    ],
                  )),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 18, 10, 10),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.width * 0.12,
                      decoration: new BoxDecoration(
                        color: const Color(0xff7c94b6),
                        image: new DecorationImage(
                          image: new NetworkImage(Strings.baseImageUrl +
                              Strings.selectedProject[0].projectImg!),
                          fit: BoxFit.fill,
                        ),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(50.0)),
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Strings.category = false;
                            Navigator.pushNamed(context, '/viewdoclist');
                          },
                          child: Container(
                            padding:
                                EdgeInsets.only(top: 5, bottom: 5, left: 5),
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              Strings.selectedProject[0].projectName!,
                              style: Drawables.adddoccontentstyle(
                                  Colors.black, 12.0, FontWeight.w600),
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.only(left: 5),
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.04,
                                height: 15.0,
                                decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                    image:
                                        new AssetImage("assets/icons/pin.png"),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(50.0)),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.36,
                                child: Text(
                                  Strings.selectedProject[0].address ??
                                      "" +
                                          ' , ' +
                                          (Strings.selectedProject[0].city ??
                                              ""),
                                  style: Drawables.adddoccontentstyle(
                                      Colors.grey, 10.0, FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 6, 0, 0),
                          child: GestureDetector(
                            onTap: () {
                              Strings.projectId =
                                  Strings.selectedProject[0].projectId!;
                              Navigator.pushNamed(context, '/projectComments');
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset("assets/icons/Comments.png",
                                    width: 15.0, height: 15.0),
                                SizedBox(width: 5),
                                Text(
                                  " Comments",
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )

                        // TextButton(onPressed: ()
                        // {
                        //   Strings.projectId = Strings.selectedProject[0].projectId!;
                        //   Navigator.pushNamed(context, '/projectComments');
                        // }, child: Text("Comments"))
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Strings.category = false;
                          Navigator.pushNamed(context, '/viewdoclist');
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outlined,
                              color: Color(0xFF0061b0),
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Text(
                                  "View Project Docs",
                                  style: Drawables.adddoccontentstyle(
                                      Colors.grey[600]!, 12.0, FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      if (Strings.roleId == 1 ||
                          Strings.roleId == 2 ||
                          Strings.roleId == 6)
                        GestureDetector(
                          onTap: () {
                            _showMyDialogProject();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Color(0xFF0061b0),
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: Text(
                                    "View Members",
                                    style: Drawables.adddoccontentstyle(
                                        Colors.grey[600]!,
                                        12.0,
                                        FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _catsList.length > 0
                ? ListView.builder(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    itemBuilder: (BuildContext ctx, int index) {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: GestureDetector(
                          onTap: () {
                            Strings.selectedCategory = [];
                            Strings.selectedCategory.add(_catsList[index]);
                            Strings.category = true;
                            Navigator.pushNamed(context, '/viewdoclist');
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 3, 20, 3),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_catsList[index].categoryName!,
                                          style: Drawables.adddoccontentstyle(
                                              Colors.black87,
                                              12.0,
                                              FontWeight.w500)),
                                      Text(
                                        "${_catsList[index].documentCounts} Documents",
                                        style: Drawables.adddoccontentstyle(
                                            Colors.grey,
                                            12.0,
                                            FontWeight.normal),
                                      )
                                    ],
                                  )),
                                  Row(
                                    children: [
                                      Text("${_catsList[index].userCount}"),
                                      IconButton(
                                        onPressed: () {
                                          // print("staff cliked");
                                          showLoading(context);
                                          getAssignedUsers(
                                              _catsList[index].categoryId!);
                                        },
                                        icon: Icon(
                                          Icons.people,
                                          color: Color(0xFF0061b0),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 14.0,
                                  )
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );

                      // return Text("hi");
                    },
                    itemCount: _catsList.length,
                  )
                : Container(
                    child: Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                  )),
          )
        ],
      ),
    );
  }

  getCategories() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.getCats(Strings.selectedProject[0].projectId!).then((response) {
      AppUtils.dismissprogress();
      print('categoiresResponse status ${response.toJson()}');
      if (response.status!) {
        setState(() {
          _catsList = response.data!;
        });
      } else {
        setState(() {
          _errText = "No Categories found !";
          // _errText = response.message;
        });
        // if (response.message != null) {
        //   AppUtils.showToastError(response.message);
        // }
        //  else {
        //   AppUtils.showToastError("No Categories found !");
        // }
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
}
