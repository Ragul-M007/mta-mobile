import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:mta/utilities/validators.dart';
import 'package:provider/provider.dart';

import 'package:mta/models/NewsRes.dart';
import '../splashscreen.dart';

bool isVerifyScreen = false;

class Login extends StatefulWidget {
  static const String routeName = "/login";

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    // return Container(child: LoginContent());

    return Scaffold(
      appBar: EmptyAppBar(),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Provider<ApiService>(
              create: (context) => ApiService.create(), child: LoginContent())),
    );
    // child: Scaffold(appBar: EmptyAppBar(), body: LoginContent())));
  }
}

class LoginContent extends StatefulWidget {
  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent>
    with TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String verificationCode;
  bool _isLoading = false;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailIdController = TextEditingController();
  TabController _tabController;

  List<NewsResData> _newsLists;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => getNewsFeeds());
    setState(() {
      _emailIdController.text = "superadmin@mta.com";
      _passwordController.text = "test12";
    });
  }

  signin() {
    setState(() {
      _isLoading = true;
    });
  }

  _login() async {
    FocusScope.of(context).unfocus();
    if (_emailIdController.text.isEmpty) {
      AppUtils.showToast("Please Enter Your Email Id");
    } else if (_passwordController.text.isEmpty) {
      AppUtils.showToast("Please Enter Your Password");
    } else {
      bool network = await Validators.networkconnectvitiy();
      if (network) {
        loginreq();
      }
    }
  }

  loginreq() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    LoginReq loginreq = LoginReq();
    loginreq.email = _emailIdController.text;
    loginreq.password = _passwordController.text;
    api.login(loginreq).then((response) {
      AppUtils.dismissprogress();
      print('loginResponse status ${response.toJson()}');

      if (response.status) {
        AppUtils.savePreferences("emailId", response.data.emailId);
        AppUtils.savePreferences("userId", response.data.userId);
        AppUtils.savePreferences("profilePic", response.data.userImg);
        Strings.profilePic = response.data.userImg;
        Strings.userID = response.data.userId;
        Strings.authToken = response.token;
        Navigator.pushNamed(context, "/setpin");
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        key: scaffoldKey,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .25,
              decoration: new BoxDecoration(
                color: Colors.white,
                image: new DecorationImage(
                  image: new AssetImage("assets/images/background1.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.4,
                margin: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 15 / 100, 20, 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFcccccc),
                        offset: const Offset(
                          -2.0,
                          6.0,
                        ),
                        blurRadius: 20.0,
                        spreadRadius: 10.0,
                      )
                    ],
                    borderRadius: BorderRadius.circular(20)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Login",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 20, 2),
                            child: Text(
                              "Email Id",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: TextField(
                            controller: _emailIdController,
                            decoration: InputDecoration(
                                hintText: "Email ID",
                                contentPadding: EdgeInsets.all(10),
                                hintStyle: TextStyle(
                                    fontSize: 14.0, color: Colors.black),
                                // border: OutlineInputBorder(),
                                border: InputBorder.none),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          decoration: BoxDecoration(
                              color: const Color(0xFFf2f3f4),
                              border:
                                  Border.all(color: const Color(0xFFf2f3f4)),
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        SizedBox(height: 5.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 20, 2),
                            child: Text(
                              "Password",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  contentPadding: EdgeInsets.all(10),
                                  hintStyle: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                  // border: OutlineInputBorder(),
                                  border: InputBorder.none),
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true),
                          decoration: BoxDecoration(
                              color: const Color(0xFFf2f3f4),
                              border:
                                  Border.all(color: const Color(0xFFf2f3f4)),
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          onTap: () {
                            _login();
                          },
                          child: Container(
                            child: Center(
                                child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            )),
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 40,
                            margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
                            decoration: BoxDecoration(
                                color: Color(0xFF0061b0),
                                borderRadius: BorderRadius.circular(25)),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              margin: EdgeInsets.fromLTRB(
                  0, MediaQuery.of(context).size.height * 0.6, 0, 0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: tabbarwidget(),
            )
          ],
        ));
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
              return _newsLists[index].feedType == "N"
                  ? Container(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.ltr,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(Strings.baseImageUrl +
                                        _newsLists[index].imgUrl)),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      _newsLists[index].titleText,
                                      textAlign: TextAlign.left,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      _newsLists[index].description,
                                      overflow: TextOverflow.clip,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )))
                  : SizedBox();
            },
            itemCount: _newsLists.length,
          )
        : SizedBox();
  }

  Widget highlights() {
    return _newsLists != null
        ? ListView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return _newsLists[index].feedType == "H"
                  ? Container(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(Strings.baseImageUrl +
                                        _newsLists[index].imgUrl)),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      _newsLists[index].titleText,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      _newsLists[index].description,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )))
                  : SizedBox();
            },
            itemCount: _newsLists.length,
          )
        : SizedBox();
  }

  getNewsFeeds() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);

    api.news().then((response) {
      AppUtils.dismissprogress();
      print('NewsResponse status ${response.toJson()}');

      if (response.status) {
        // Navigator.pushNamed(ctx, "/dashboard");
        setState(() {
          _newsLists = response.data;
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
