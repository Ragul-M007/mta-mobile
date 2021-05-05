import 'dart:ui';
import 'package:flutter/material.dart';
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
      _emailIdController.text = "";
      _passwordController.text = "";
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
      AppUtils.showToastError("Please Enter Your Email Id");
    } else if (_passwordController.text.isEmpty) {
      AppUtils.showToastError("Please enter Your Password");
    } else if (_passwordController.text.trim() == "") {
      AppUtils.showToastError("Please enter Your Password");
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
    loginreq.token = Strings.fcmToken;
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
        AppUtils.showToastError(response.message);
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
                          padding: EdgeInsets.all(25),
                          child: GestureDetector(
                            onTap: () {
                              _showMyDialog(
                                  Strings.baseImageUrl +
                                      _newsLists[index].imgUrl,
                                  _newsLists[index].titleText,
                                  _newsLists[index].description);
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
                                                  _newsLists[index].imgUrl)),
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
                                        _newsLists[index].titleText,
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
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
                                                serverDate: _newsLists[index]
                                                    .updatedAt),
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
                          padding: EdgeInsets.all(25),
                          child: GestureDetector(
                            onTap: () {
                              _showMyDialog(
                                  Strings.baseImageUrl +
                                      _newsLists[index].imgUrl,
                                  _newsLists[index].titleText,
                                  _newsLists[index].description);
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
                                                  _newsLists[index].imgUrl)),
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
                                        _newsLists[index].titleText,
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
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
                                                serverDate: _newsLists[index]
                                                    .updatedAt),
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

  static String calculateTimeDifferenceBetween({@required String serverDate}) {
    DateTime startDate = DateTime.parse(serverDate);
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
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: GridView.count(
                      primary: false,
                      crossAxisCount: 1,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  new Icon(Icons.close,
                                      size: 22.0, color: Colors.black),
                                ]),
                            Container(
                              child: image(imgurl, 100.0, 100.0),
                            ),
                          ],
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                        ),
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
