import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
//import 'package:mta/models/ContactusRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

FancyDrawerController _controller;

class Contactus extends StatefulWidget {
  static const String routeName = "/contactus";

  @override
  _ContactusState createState() => _ContactusState();
}

class _ContactusState extends State<Contactus>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 100))
      ..addListener(() {
        setState(() {
          // print(Strings.authToken);
          Strings.currentmenuvalue = 5;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(child: LoginContent());

    return Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: Container(
          decoration:
              Drawables.menudecorationImage("assets/images/Menubg.png", 0.0),
          child: FancyDrawerWrapper(
            backgroundColor: Colors.transparent,
            controller: _controller,
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
                            "assets/images/logo.jpeg", 50.0)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "MTA Architects",
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
                menutitle: "Projects",
              ),
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
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/settings", currentmenu: 8);
                },
                selectedmenuvalue: 8,
                menutitle: "Settings",
              ),
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/login", currentmenu: 9);
                },
                selectedmenuvalue: 9,
                menutitle: "Logout",
              ),
            ],
            child: Scaffold(
              backgroundColor: Colors.grey[300],
              appBar: EmptyAppBar(),
              body: ContactusContent(),
            ),
          ),
        ));
  }

  menuRedirect({@required String routename, int currentmenu}) {
    setState(() {
      Strings.currentmenuvalue = currentmenu;
    });
    if (routename == "/login") {
      AppUtils.clearAllPreferences();
      //Navigator.pop(context);
      Navigator.popAndPushNamed(context, routename);
    } else {
      //Navigator.pop(context);
      Navigator.pushNamed(context, routename);
    }
  }
}

class ContactusContent extends StatefulWidget {
  @override
  _ContactusContentState createState() => _ContactusContentState();
}

class _ContactusContentState extends State<ContactusContent> {
  final mobileField = TextEditingController();
  final userType = TextEditingController();
  final password = TextEditingController();

  //ContactusRes _profileData;
  bool loader = false;

  var address = '';

  @override
  void initState() {
    mobileField.text = "9987878898";
    userType.text = "mtaenquiry@gmail.com";
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => getContactus());
    //getContactus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: loader
            ? Padding(padding: EdgeInsets.all(0.0))
            : Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * .32,
                    decoration: BoxDecoration(
                      color: Color(0xFF0061b0),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: Drawables.menudecorationImage(
                                    "assets/images/logo.jpeg", 50.0)),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "MTA Architects",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                // Text(
                                //   "mtaenquiry@gmail.com",
                                //   style: TextStyle(
                                //       color: Colors.white, fontSize: 15),
                                // ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height * .35, 0, 0),
                    padding: EdgeInsets.all(5),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _controller.toggle();
                            },
                            child: Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Contact Us",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height * .25, 20, 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Row(
                          children: [
                            Icon(Icons.pin_drop),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "MTA , 12th street, RJ Nagar, Tiruppur",
                              overflow: TextOverflow.clip,
                            )
                          ],
                        )),
                  ),
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(
                          10, MediaQuery.of(context).size.height * .5, 10, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Phone Number",
                            style: TextStyle(
                                color: Color(0xFF0061b0),
                                fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: mobileField,
                            decoration:
                                InputDecoration(prefixIcon: Icon(Icons.call)),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Email",
                            style: TextStyle(
                                color: Color(0xFF0061b0),
                                fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: userType,
                            decoration:
                                InputDecoration(prefixIcon: Icon(Icons.email)),
                          ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          // Text(
                          //   "Password",
                          //   style: TextStyle(
                          //       color: Color(0xFF0061b0),
                          //       fontWeight: FontWeight.bold),
                          // ),
                          // TextField(
                          //   controller: password,
                          //   decoration: InputDecoration(
                          //       prefixIcon: Icon(Icons.vpn_key),
                          //       suffixText: "Change Password",
                          //       suffixStyle:
                          //           TextStyle(color: Color(0xFF0061b0))),
                          // )
                        ],
                      )),
                ],
              ));
  }

  // getContactus() {
  //   AppUtils.showprogress();
  //   final api = Provider.of<ApiService>(context, listen: false);

  //   api.profile().then((response) {
  //     AppUtils.dismissprogress();
  //     print('profileResponse status ${response.toJson()}');
  //     setState(() {
  //       loader = false;
  //       _profileData = response;
  //       mobileField.text = _profileData.mobileNo;
  //       userType.text = _profileData.role;
  //       address = _profileData.area +
  //           " , " +
  //           _profileData.city +
  //           " , " +
  //           _profileData.state;
  //     });
  //   }).catchError((onError) {
  //     AppUtils.dismissprogress();
  //     print(onError.toString());
  //   });
  // }

  Widget _loader() {
    return Container(
      width: MediaQuery.of(context).size.width, //70.0,
      height: MediaQuery.of(context).size.height * 86,
      child: Center(
        child: CircularProgressIndicator(),
      ),
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
