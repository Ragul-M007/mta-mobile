import 'package:flutter/material.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

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


            if(Strings.fromProjects == true)
            {
                Navigator.pushNamed(context, '/projects');
            }
            else
            {
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
  List<FetchMapedUsersData>? users;
  String _errText = "";
  void initState() {
    super.initState();
    getUserCats();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getCategories());
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

  Future<void> _showMyDialogProject() async {
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("role--> ${Strings.roleId}");
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.12,
                height: MediaQuery.of(context).size.width * 0.12,
                decoration: new BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: new DecorationImage(
                    image: new NetworkImage(Strings.baseImageUrl +
                        Strings.selectedProject[0].projectImg!),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Strings.category = false;
                      Navigator.pushNamed(context, '/viewdoclist');
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            Strings.selectedProject[0].projectName!,
                            style: Drawables.adddoccontentstyle(
                                Colors.black, 18.0, FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
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
                          Container(
                            width: MediaQuery.of(context).size.width * 0.04,
                            height: 15.0,
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
                                image: new AssetImage("assets/icons/pin.png"),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(50.0)),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.36,
                            child: Text(
                              Strings.selectedProject[0].address! +
                                  ' , ' +
                                  Strings.selectedProject[0].city!,
                              style: Drawables.adddoccontentstyle(
                                  Colors.grey, 13.0, FontWeight.normal),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
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
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                "View Members",
                                style: Drawables.adddoccontentstyle(
                                    Colors.grey[600]!, 12.0, FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  // Container(
                  //   width: 15.0,
                  //   height: 15.0,
                  //   decoration: new BoxDecoration(
                  //     image: new DecorationImage(
                  //       image: new AssetImage("assets/icons/pin.png"),
                  //       fit: BoxFit.fill,
                  //     ),
                  //     borderRadius:
                  //         new BorderRadius.all(new Radius.circular(50.0)),
                  //   ),
                  // ),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     Text(
                  //       Strings.selectedProject[0].address! +
                  //           ' , ' +
                  //           Strings.selectedProject[0].city!,
                  //       style: Drawables.adddoccontentstyle(
                  //           Colors.grey, 13.0, FontWeight.normal),
                  //     ),
                  //     SizedBox(width:20),
                  //     Icon(
                  //       Icons.info_outlined,
                  //       color: Color(0xFF0061b0),
                  //       size: 20,
                  //     ),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     Align(
                  //       child: SizedBox(
                  //         width: MediaQuery.of(context).size.width * 0.25,
                  //         child: Text(
                  //           "View Project Docs",
                  //           style: Drawables.adddoccontentstyle(
                  //               Colors.grey[600]!, 12.0, FontWeight.w600),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: _catsList.length > 0
              ? ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemBuilder: (BuildContext ctx, int index) {
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          print("category check ${_catsList[index]}");
                          Strings.selectedCategory = [];
                          Strings.selectedCategory.add(_catsList[index]);
                          Strings.category = true;
                          Navigator.pushNamed(context, '/viewdoclist');
                        },
                        child: Container(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          _catsList[index].categoryName!,
                                          style: Drawables.adddoccontentstyle(
                                              Colors.black87,
                                              14.0,
                                              FontWeight.w500))),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 14.0,
                                  )
                                ],
                              )),
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
