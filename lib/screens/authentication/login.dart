import 'dart:io';
import 'dart:ui';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/ChangePassReq.dart';
import 'package:mta/models/ForgotPassReq.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/validateOTPReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:mta/utilities/validators.dart';
import 'package:provider/provider.dart';

import 'package:mta/models/NewsRes.dart';
import '../splashscreen.dart';

bool isVerifyScreen = false;
String? codeVerifyField;
String? verificationCode;
String emailIdforVerification = '';

FocusNode one = new FocusNode();
FocusNode two = new FocusNode();
FocusNode three = new FocusNode();
FocusNode four = new FocusNode();
FocusNode five = new FocusNode();

final oneT = TextEditingController();
final twoT = TextEditingController();
final threeT = TextEditingController();
final fourT = TextEditingController();
final fiveT = TextEditingController();
final changePassConfirm = TextEditingController();
final changePassNew = TextEditingController();

final forgotPassEmailID = TextEditingController();

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
          child: WillPopScope(
              onWillPop: () async {
                _onWillPop();
                return false;
              },
              child: Provider<ApiService>(
                  create: (context) => ApiService.create(),
                  child: LoginContent())),
        ));
    // child: Scaffold(appBar: EmptyAppBar(), body: LoginContent())));
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
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
              'Do you want to exit an App',
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
                onPressed: () => exit(0),
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
  }
}

class LoginContent extends StatefulWidget {
  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent>
    with TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String? verificationCode;
  bool _isLoading = false;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailIdController = TextEditingController();
  TabController? _tabController;

  List<NewsResData>? _newsLists;

  @override
  void initState() {
    super.initState();
    certifcatecheck();
    _tabController = new TabController(length: 2, vsync: this);
    WidgetsBinding.instance?.addPostFrameCallback((_) => getNewsFeeds());
    setState(() {
      _emailIdController.text = "";
      _passwordController.text = "";
      // _emailIdController.text = "superadmin@mta.com";
      // _passwordController.text = "test12";
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
      AppUtils.showToastErrorTop("Please Enter Your Email Id");
    } else if (_passwordController.text.isEmpty) {
      AppUtils.showToastErrorTop("Please enter Your Password");
    } else if (_passwordController.text.trim() == "") {
      AppUtils.showToastErrorTop("Please enter Your Password");
    }else if(_emailIdController.text.trim() == "accounts@multitechcorp.in")
    {
        AppUtils.showToastError("Sorry! You doesn't have access on Mobile App. Kindly Login from the Web Application.");
    }
     else {
      bool network = await Validators.networkconnectvitiy();
      if (network) 
      {
        loginreq();
      }
    }
  }

  loginreq() 
  {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    print("api--->  {$api}");
    LoginReq loginreq = LoginReq();
    loginreq.email = _emailIdController.text;
    loginreq.password = _passwordController.text;
    loginreq.token = Strings.fcmToken;
    Strings.authToken = '';
    print("loqinrequest ---> ${loginreq}");
    api.login(loginreq).then((response) 
    {
      AppUtils.dismissprogress();
      print('loginResponse status ${response.toJson()}');
      assignroles()
      {
        if (response.data?.role == "ADMIN")
        {
            Strings.roleId = 1;
        }
        else if(response.data?.role == "STAFF")
        {
            Strings.roleId = 2;
        }
        else if(response.data?.role == "VENDOR")
        {
            Strings.roleId = 3;
        }else if(response.data?.role == "CONSULTANTS")
        {
            Strings.roleId = 4;
        }
        else if(response.data?.role == "CONTRACTORS")
        {
            Strings.roleId = 5;
        }
        else if(response.data?.role == "CLIENT")
        {
            Strings.roleId = 6;
        }
      }
      if (response.status!) {
        print("inside status");
        AppUtils.savePreferences("emailId", response.data?.emailId);
        AppUtils.savePreferences("userId", response.data?.userId);
        if (response.data?.userImg != null) {
          print("inside if img");
          AppUtils.savePreferences("profilePic", response.data?.userImg);
          Strings.profilePic = response.data!.userImg!;
        } else {
          print("inside elseif img");
          AppUtils.savePreferences("profilePic", "");
          Strings.profilePic = "";
        }
        Strings.userID = response.data!.userId;
        Strings.username = response.data!.name;
        assignroles();
        Strings.authToken = response.token!;
        print("role${Strings.roleId}");
        Navigator.pushNamed(context, "/setpin");
      } else 
      {
        showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Login Failed",style: TextStyle(color: Colors.red),),
                  content: Text(response.message ?? "Unknown Error"),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
        //AppUtils.showToastErrorTop(response.message!);
      }
      
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          key: scaffoldKey,
          child: Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .25,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  image: new DecorationImage(
                    image: new AssetImage("assets/images/logo.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.44,
                  margin: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).size.height * 12 / 100, 20, 0),
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
                          ),
                          SizedBox(height: 10.0),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 10, 20, 2),
                              child: GestureDetector(
                                onTap: () {
                                  _forgotPass();
                                },
                                child: Text(
                                  "Forgot Password ?",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
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
          )),
    );
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
                                                  (_newsLists?[index].imgUrl ?? ""))),
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
  certifcatecheck()
  {
    Dio _dio = Dio();
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
             (HttpClient dioClient) {
           dioClient.badCertificateCallback =
               ((X509Certificate cert, String host, int port) => true);
           return dioClient;
         };
  }

  getNewsFeeds() {
    AppUtils.showprogress();
    Dio _dio = Dio();
    final api = Provider.of<ApiService>(context, listen: false);
    print(api);
    api.news().then((response) 
    {
      AppUtils.dismissprogress();
      print('NewsResponse status ${response.toJson()}');

      if (response.status!) {
        // Navigator.pushNamed(ctx, "/dashboard");
        setState(() {
          _newsLists = response.data!;
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
    print("api news----->{$api.news()}");
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

  Future<void> _otpVerify() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextResetPin) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: GestureDetector(
                onTap: () {
                  Navigator.of(contextResetPin).pop();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(contextResetPin).size.width * 0.75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          new Icon(Icons.close,
                              size: 22.0, color: Colors.black),
                        ],
                      ),
                    ),
                    Text(
                      "OTP verification",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Enter 5 digit verification code that has been sent to your registered Email",
                      style: TextStyle(color: const Color(0xFF9e9e9e)),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    _boxBuilder(contextResetPin),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        codeVerifyField = oneT.text +
                            twoT.text +
                            threeT.text +
                            fourT.text +
                            fiveT.text;

                        if (codeVerifyField!.length < 5) {
                          AppUtils.showToastError("Please Enter code");
                        } else {
                          otpVerifyCall(contextResetPin);
                        }
                      },
                      child: Container(
                        child: Center(
                            child: Text(
                          "VERIFY",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                        width: MediaQuery.of(contextResetPin).size.width * 0.8,
                        height: 40,
                        margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
                        decoration: BoxDecoration(
                            color: Color(0xFF0061b0),
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    )
                  ],
                )),
          ),
        );
      },
    );
  }

  Widget _boxBuilder(contextResetPin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _box(1, contextResetPin),
        _box(2, contextResetPin),
        _box(3, contextResetPin),
        _box(4, contextResetPin),
        _box(5, contextResetPin),
      ],
    );
  }

  Widget _box(val, contextResetPin) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        alignment: Alignment.center,
        height: 50,
        width: 40,
        child: TextField(
          keyboardType: TextInputType.number,
          maxLength: 1,
          autofocus: true,
          controller: val == 1
              ? oneT
              : val == 2
                  ? twoT
                  : val == 3
                      ? threeT
                      : val == 4
                          ? fourT
                          : fiveT,
          focusNode: val == 1
              ? one
              : val == 2
                  ? two
                  : val == 3
                      ? three
                      : val == 4
                          ? four
                          : five,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10), counterText: ''),
          textAlign: TextAlign.center,
          onChanged: (value) {
            print(value);

            if (value == '') {
              FocusScope.of(contextResetPin).requestFocus(
                val == 5
                    ? four
                    : val == 4
                        ? three
                        : val == 3
                            ? two
                            : val == 2
                                ? one
                                : null,
              );
            } else {
              FocusScope.of(contextResetPin).requestFocus(
                val == 1
                    ? two
                    : val == 2
                        ? three
                        : val == 3
                            ? four
                            : val == 4
                                ? five
                                : null,
              );
              print("not null");
            }
          },
        ),
      ),
    );
  }

  Future<void> _changePass() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctxd) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: GestureDetector(
                onTap: () {
                  Navigator.of(ctxd).pop();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(ctxd).size.width * 0.75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          new Icon(Icons.close,
                              size: 22.0, color: Colors.black),
                              
                        ],
                      ),
                    ),
                    Text(
                      "Set Password",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "New Password",
                      style: TextStyle(
                          color: Color(0xFF0061b0),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: changePassNew,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key,
                              size: 14, color: Color(0xFF0061b0))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Confirm Password",
                      style: TextStyle(
                          color: Color(0xFF0061b0),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: changePassConfirm,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key,
                              size: 14, color: Color(0xFF0061b0))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        setNewPass(ctxd);
                      },
                      child: Container(
                        child: Center(
                            child: Text(
                          "SAVE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                        width: MediaQuery.of(ctxd).size.width * 0.8,
                        height: 40,
                        margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
                        decoration: BoxDecoration(
                            color: Color(0xFF0061b0),
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    )
                  ],
                )),
          ),
        );
      },
    );
  }

  Future<void> _forgotPass() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctxd) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: GestureDetector(
                onTap: () {
                  Navigator.of(ctxd).pop();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(ctxd).size.width * 0.75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          new Icon(Icons.close,
                              size: 22.0, color: Colors.black),
                        ],
                      ),
                    ),
                    Text(
                      "Forgot Password",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Regitered Email Id",
                      style: TextStyle(
                          color: Color(0xFF0061b0),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: forgotPassEmailID,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email,
                              size: 14, color: Color(0xFF0061b0))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        _generateOtp(context);
                      },
                      child: Container(
                        child: Center(
                            child: Text(
                          "SUBMIT",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                        width: MediaQuery.of(ctxd).size.width * 0.8,
                        height: 40,
                        margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
                        decoration: BoxDecoration(
                            color: Color(0xFF0061b0),
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    )
                  ],
                )),
          ),
        );
      },
    );
  }

  _generateOtp(ctx) {
    if (forgotPassEmailID.text == "" || forgotPassEmailID.text.isEmpty) {
      AppUtils.showToastErrorTop("Please enter your registered Email Id");
    } else {
      AppUtils.showprogress();
      final api = Provider.of<ApiService>(context, listen: false);
      ForgotPassReq request = ForgotPassReq();
      request.emailId = forgotPassEmailID.text;

      api.forgotPass(request).then((response) {
        AppUtils.dismissprogress();
        print('Response status ${response.toJson()}');
        if (response.status!) {
          Navigator.of(ctx).pop();
          emailIdforVerification = forgotPassEmailID.text;
          forgotPassEmailID.text = '';
          _otpVerify();
        } else {
          AppUtils.showToastError(response.message!);
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        print(onError.toString());
      });
    }
  }

  otpVerifyCall(ctx) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    ValidateOTPReq request = ValidateOTPReq();
    request.emailId = emailIdforVerification;
    request.otp = codeVerifyField;

    api.otpVerify(request).then((response) {
      AppUtils.dismissprogress();
      print('Response status ${response.toJson()}');
      if (response.status!) {
        Navigator.of(ctx).pop();
        oneT.text = '';
        twoT.text = '';
        threeT.text = '';
        fourT.text = '';
        fiveT.text = '';
        _changePass();
      } else {
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  setNewPass(ctx) {
    if (changePassNew.text == '') {
      AppUtils.showToastErrorTop("Please Enter Password");
    } else if (changePassConfirm.text == '') {
      AppUtils.showToastErrorTop("Please Enter Confirm Password");
    } else if (changePassNew.text != changePassConfirm.text) {
      AppUtils.showToastErrorTop("Password & Confirm Password are not same");
    } else {
      AppUtils.showprogress();
      final api = Provider.of<ApiService>(context, listen: false);
      ChangePassReq request = ChangePassReq();
      request.emailId = emailIdforVerification;
      request.newPassword = changePassNew.text;

      api.changePass(request).then((response) {
        AppUtils.dismissprogress();
        print('Response status ${response.toJson()}');
        if (response.status!) {
          changePassNew.text = "";
          changePassConfirm.text = "";
          Navigator.of(ctx).pop();

          AppUtils.showToastSuccess(response.message!);
        } else {
          AppUtils.showToastErrorTop(response.message!);
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        print(onError.toString());
      });
    }
  }
}
