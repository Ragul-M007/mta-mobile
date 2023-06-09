import 'dart:ui';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/NewsRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

FancyDrawerController? _controller;

class Newshighlights extends StatelessWidget {
  const Newshighlights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: NewshighlightsContent(),
    );
  }
}

class NewshighlightsContent extends StatefulWidget {
  static const String routeName = "/newshighlights";
  @override
  _NewshighlightsContentState createState() => _NewshighlightsContentState();
}

class _NewshighlightsContentState extends State<NewshighlightsContent>
    with TickerProviderStateMixin {
  List<NewsResData>? _newsLists;
  TabController? _tabController;

  void initState() {
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {
          Strings.currentmenuvalue = 7;
        });
      });

    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    WidgetsBinding.instance?.addPostFrameCallback((_) => getNewsFeeds());
  }

  menuopen() {}

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Material(
        child: Container(
      decoration:
          Drawables.menudecorationImage("assets/images/Menubg.png", 0.0),
      child: FancyDrawerWrapper(
        backgroundColor: Colors.transparent,
        controller: _controller!,
        drawerItems: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 30),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                new Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: Drawables.menudecorationImage(
                        "assets/images/logo.jpg", 50.0)),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "MTA Konnect",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )
              ],
            ),
          ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/dashboard", currentmenu: 1);
            },
            selectedmenuvalue: 1,
            menutitle: Strings.roleId == 7 ? "Home":"Projects",
          ),
          if (Strings.roleId == 1 || Strings.roleId == 2 || Strings.roleId == 5)
               menuoption(
                  ontab: () {
                    menuRedirect(routename: "/attendance", currentmenu: 2);
                  },
                  selectedmenuvalue: 2,
                  menutitle: "Attendance",
                ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/profile", currentmenu: 3);
            },
            selectedmenuvalue: 3,
            menutitle: "Profile",
          ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/notification", currentmenu: 4);
            },
            selectedmenuvalue: 4,
            menutitle: "Notification",
          ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/contactus", currentmenu: 5);
            },
            selectedmenuvalue: 5,
            menutitle: "Contact Us",
          ),
          // menuoption(
          //   ontab: () {
          //     menuRedirect(routename: "/privacypolicy", currentmenu: 6);
          //   },
          //   selectedmenuvalue: 6,
          //   menutitle: "Privacy Policy",
          // ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/newshighlights", currentmenu: 7);
            },
            selectedmenuvalue: 7,
            menutitle: "News & Highlights",
          ),
          // menuoption(
          //   ontab: () {
          //     menuRedirect(routename: "/settings", currentmenu: 8);
          //   },
          //   selectedmenuvalue: 8,
          //   menutitle: "Settings",
          // ),
          menuoption(
            ontab: () {
showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text(
              "Are you sure ?",
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0061b0),
                  fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Do you want to logout from the App',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'No',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: (){
                  menuRedirect(routename: "/login", currentmenu: 9);
                  AppUtils.removeDeviceId(context);
                }
,
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
        );            },
            selectedmenuvalue: 9,
            menutitle: "Logout",
          ),
        ],
        child: Scaffold(
            appBar: mainappbar(ontab: menuopen, title: "News & Highlights", controller: _controller),
            // mainappbar(
            //     ontab: menuopen,
            //     title: "News & Heighlights",
            //     controller: _controller),
          
            body: tabbarwidget()),
      ),
    ));
  }

  menuRedirect({@required String? routename, int? currentmenu}) 
  {
    setState(() {
      Strings.currentmenuvalue = currentmenu!;
    });
    if (routename == "/login") 
    {
      //AppUtils.clearAllPreferences();
      // Navigator.popAndPushNamed(context, routename);
      Navigator.popAndPushNamed(context, "/login");
    } else 
    {
      Navigator.pushNamed(context, routename!);
    }
  }

  Widget tabbarwidget() {
    return Container(

        // padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width * 1.0,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              child: TabBar(
                tabs: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Text('News Feeds',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF272626))),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Text('Highlights',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9e9e9e))),
                  )
                ],
                unselectedLabelColor: const Color(0xffacb3bf),
                indicatorColor: Color(0xFF0061b0),
                labelColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3.0,
                indicatorPadding: EdgeInsets.all(10),
                isScrollable: true,
                controller: _tabController,
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: <Widget>[
                newsFeeds(),
                highlights()
                //
              ]),
            )
          ],
        ));
  }

  Widget newsFeeds() {
    return _newsLists != null
        ? ListView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return _newsLists![index].feedType == "N"
                  ? Container(
                      child: Padding(
                          padding: EdgeInsets.all(25),
                          child: GestureDetector(
                            onTap: () {
                              _showMyDialog(
                                  Strings.baseImageUrl +
                                      _newsLists![index].imgUrl!,
                                  _newsLists![index].titleText,
                                  _newsLists![index].description);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.ltr,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: 80,
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: Image.network(
                                              Strings.baseImageUrl +
                                                  (_newsLists![index].imgUrl ?? ""))),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _newsLists![index].titleText!,
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        _newsLists![index].description!,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 18.0,
                                            height: 18.0,
                                            child: IconButton(
                                              padding: new EdgeInsets.all(0.0),
                                              color: Colors.grey,
                                              icon: new Icon(Icons.update,
                                                  size: 18.0),
                                              onPressed: () {},
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            calculateTimeDifferenceBetween(
                                                serverDate: _newsLists![index]
                                                    .updatedAt!),
                                            textAlign: TextAlign.left,
                                            textDirection: TextDirection.ltr,
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )))
                  : SizedBox();
            },
            itemCount: _newsLists!.length,
          )
        : SizedBox();
  }

  Widget highlights() {
    return _newsLists != null
        ? ListView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return _newsLists![index].feedType == "H"
                  ? Container(
                      child: Padding(
                          padding: EdgeInsets.all(25),
                          child: GestureDetector(
                            onTap: () {
                              _showMyDialog(
                                  Strings.baseImageUrl +
                                      _newsLists![index].imgUrl!,
                                  _newsLists![index].titleText,
                                  _newsLists![index].description);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.ltr,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: 80,
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: Image.network(
                                              Strings.baseImageUrl +
                                                  _newsLists![index].imgUrl!)),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _newsLists![index].titleText!,
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        _newsLists![index].description!,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 18.0,
                                            height: 18.0,
                                            child: IconButton(
                                              padding: new EdgeInsets.all(0.0),
                                              color: Colors.grey,
                                              icon: new Icon(Icons.update,
                                                  size: 18.0),
                                              onPressed: () {},
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            calculateTimeDifferenceBetween(
                                                serverDate: _newsLists![index]
                                                    .updatedAt!),
                                            textAlign: TextAlign.left,
                                            textDirection: TextDirection.ltr,
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )))
                  : SizedBox();
            },
            itemCount: _newsLists!.length,
          )
        : SizedBox();
  }

  getNewsFeeds() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);

    api.news().then((response) {
      AppUtils.dismissprogress();
      print('NewsResponse status ${response.toJson()}');

      if (response.status!) {
        // Navigator.pushNamed(ctx, "/dashboard");
        setState(() {
          _newsLists = response.data;
        });
      } else {
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  static String calculateTimeDifferenceBetween({@required String? serverDate}) {
    DateTime startDate = DateTime.parse(serverDate!);
    DateTime endDate = DateTime.now();
    int seconds = endDate.difference(startDate).inSeconds;
    if (seconds < 60)
      return '${seconds.abs()} second';
    else if (seconds >= 60 && seconds < 3600)
      return '${startDate.difference(endDate).inMinutes.abs()} minute';
    else if (seconds >= 3600 && seconds < 86400)
      return '${startDate.difference(endDate).inHours.abs()} hour';
    else
      return '${startDate.difference(endDate).inDays.abs()} day';
  }

  Future<void> _showMyDialog(imgurl, title, desc) async {
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              new Icon(Icons.close,
                                  size: 22.0, color: Colors.black),
                            ]),
                        Container(
                          child: image(imgurl, 100.0, 100.0),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0061b0),
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          desc,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        // ,
                      ],
                    ),
                  ))),
        );
      },
    );
  }

  Widget image(String img, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: new BoxDecoration(
        color: const Color(0xff7c94b6),
        image: new DecorationImage(
          image: new NetworkImage(img),
          fit: BoxFit.fill,
        ),
        borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
      ),
    );
  }
}
