import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'package:mta/models/ContactusRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

FancyDrawerController? _controller;

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
          Strings.currentmenuvalue = 6;
        });
      });
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose controller
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
              if (Strings.roleId != 6)
                menuoption(
                  ontab: () {
                    Strings.fromProjects = false;
                    menuRedirect(routename: "/teamsDashboard", currentmenu: 1);
                  },
                  selectedmenuvalue: 1,
                  menutitle: Strings.roleId == 7 ? "Home" : "Teams",
                ),
              if (Strings.roleId != 7)
                menuoption(
                  ontab: () {
                    Strings.fromProjects = true;
                    menuRedirect(routename: "/projects", currentmenu: 2);
                  },
                  selectedmenuvalue: 2,
                  menutitle: "Projects",
                ),
              if (Strings.roleId == 1 ||
                  Strings.roleId == 2 ||
                  Strings.roleId == 5)
                menuoption(
                  ontab: () {
                    menuRedirect(routename: "/attendance", currentmenu: 3);
                  },
                  selectedmenuvalue: 3,
                  menutitle: "Attendance",
                ),
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/profile", currentmenu: 4);
                },
                selectedmenuvalue: 4,
                menutitle: "Profile",
              ),
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/notification", currentmenu: 5);
                },
                selectedmenuvalue: 5,
                menutitle: "Notification",
              ),
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/contactus", currentmenu: 6);
                },
                selectedmenuvalue: 6,
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
                          onPressed: () {
                            print("yesy");
                            menuRedirect(routename: "/login", currentmenu: 9);
                            AppUtils.savePreferences("easyAccess", "N");
                            AppUtils.removeDeviceId(context);
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

  menuRedirect({@required String? routename, int? currentmenu}) {
    setState(() {
      Strings.currentmenuvalue = currentmenu!;
    });
    if (routename == "/login") {
      //AppUtils.clearAllPreferences();
      //Navigator.pop(context);
      Navigator.popAndPushNamed(context, "/login");
      //Navigator.popAndPushNamed(context, routename);
    } else {
      //Navigator.pop(context);
      Navigator.pushNamed(context, routename!);
    }
  }
}

class ContactusContent extends StatefulWidget {
  @override
  _ContactusContentState createState() => _ContactusContentState();
}

class _ContactusContentState extends State<ContactusContent> {
  final mobileField = TextEditingController();
  final mobileField1 = TextEditingController();
  final mobilechennai = TextEditingController();
  final emailChennai = TextEditingController();
  final twitter = TextEditingController();
  final instagram = TextEditingController();
  final linkedin = TextEditingController();
  final socialLinksData = [
    {
      "social_media": "Instagram",
      "url": "",
      "image": "assets/icons/instagram.png"
    },
    {"social_media": "Twitter", "url": "", "image": "assets/icons/twitter.png"},
    {
      "social_media": "Linkedin",
      "url": "",
      "image": "assets/icons/linkedin.png"
    }
  ];

  final userType = TextEditingController();
  final password = TextEditingController();

  //ContactusRes _profileData;
  bool loader = false;

  var address = '';

  @override
  void initState() {
    mobileField.text = "98940 61990, 98940 71990,\n0421-4341114 ";
    mobileField1.text = "";
    mobilechennai.text = "96292 11990, 044-22342848";
    //mobileField2.text = "0421-4341114";
    userType.text = "info@multitechcorp.in";
    emailChennai.text = "info@mtadesigns.com";
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getSocialsMediaLinks());
    //getContactus();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: SafeArea(
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
                                        "assets/images/logo.jpg", 50.0)),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "MTA Konnect",
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
                            0, MediaQuery.of(context).size.height * .31, 0, 0),
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
                                  _controller?.toggle();
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
                        margin: EdgeInsets.fromLTRB(20,
                            MediaQuery.of(context).size.height * .25, 20, 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pin_drop),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "MTA Tirupur",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("74/33, Singaravelan Nagar,"),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                          "Sakthi Theatre Road, Tirupur - 641603")
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Phone Number",
                                    style: TextStyle(
                                        color: Color(0xFF0061b0),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextField(
                                    enabled: false,
                                    controller: mobileField,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.call)),
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
                                    enabled: false,
                                    controller: userType,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.email)),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.pin_drop),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "MTA Chennai",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text("25/41 Vembuli Subedar St,"),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text("Alandur, Guindy - 600016"),
                                          SizedBox(
                                            height: 3,
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Phone Number",
                                    style: TextStyle(
                                        color: Color(0xFF0061b0),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextField(
                                    enabled: false,
                                    controller: mobilechennai,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.call)),
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
                                    enabled: false,
                                    controller: emailChennai,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.email)),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: socialLinks(),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(10,
                              MediaQuery.of(context).size.height * .40, 10, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
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
                  )));
  }

  Widget socialLinks() {
    return Container(
        height: 50,
        alignment: Alignment.center,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: socialLinksData.length,
            itemBuilder: (context, index) {
              return IconButton(
                  icon: Image.asset(socialLinksData[index]["image"]!),
                  onPressed: () {
                    launchUrl(Uri.parse(socialLinksData[index]["link"]!));
                  });
            }));
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

  getSocialsMediaLinks() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);

    api.getSocialsBackLink().then((response) {
      print('profileResponse status ${response.toJson()}');
      socialLinksData.forEach((element) {
        if (element['social_media'] == "Instagram") {
          element['link'] = response.data![0].instagramLink!;
        } else if (element['social_media'] == "Twitter") {
          element['link'] = response.data![0].twitterLink!;
        } else if (element['social_media'] == "Linkedin") {
          element['link'] = response.data![0].linkedin!;
        }
      });
      setState(() {
        loader = false;
      });

      AppUtils.dismissprogress();
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

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
