import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mta/models/ForgotPassReq.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/SetPinReq.dart';
// import 'package:mta/models/validateOTPReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/comments/comments.dart';
import 'package:mta/screens/comments/replies.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mta/screens/attendance/attendance.dart';

import '../../models/validateOTPReq.dart';
import '../doucument/viewdoclist.dart';

class Verifypin extends StatefulWidget {
  static const String routeName = "/verifypin";

  @override
  _VerifypinState createState() => _VerifypinState();
}

class _VerifypinState extends State<Verifypin> {
  final mobileField = TextEditingController();
  String? codeVerifyField;
  String? verificationCode;
  String emailIdforVerification = '';

  bool _isLoading = false;

  FocusNode one = new FocusNode();
  FocusNode two = new FocusNode();
  FocusNode three = new FocusNode();
  FocusNode four = new FocusNode();

  FocusNode Resetone = new FocusNode();
  FocusNode Resettwo = new FocusNode();
  FocusNode Resetthree = new FocusNode();
  FocusNode Resetfour = new FocusNode();
  FocusNode Resetfive = new FocusNode();

  final oneT = TextEditingController();
  final twoT = TextEditingController();
  final threeT = TextEditingController();
  final fourT = TextEditingController();

  final ResetfiveT = TextEditingController();
  final ResetoneT = TextEditingController();
  final ResettwoT = TextEditingController();
  final ResetthreeT = TextEditingController();
  final ResetfourT = TextEditingController();

  final forgotPassEmailID = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("Testing message--> ${Strings.testing}");
    print("Testing bool--> ${Strings.fromNotificationComments}");
  }

  BuildContext? ctx;
  Future<bool> _onWillPop() async {
    return (await showDialog(
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
        )) ??
        false;
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
                    _boxBuilder1(contextResetPin),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        codeVerifyField = ResetoneT.text +
                            ResettwoT.text +
                            ResetthreeT.text +
                            ResetfourT.text +
                            ResetfiveT.text;

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

  otpVerifyCall(ctx) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    ValidateOTPReq request = ValidateOTPReq();
    request.emailId = emailIdforVerification;
    request.otp = codeVerifyField;

    print("data ${request.emailId}");
    print("data ${request.otp}");

    api.otpVerify(request).then((response) {
      AppUtils.dismissprogress();
      print('Response status ${response.toJson()}');
      if (response.status!) {
        Navigator.of(ctx).pop();
        ResetoneT.text = '';
        ResettwoT.text = '';
        ResetthreeT.text = '';
        ResetfourT.text = '';
        ResetfiveT.text = '';

        Strings.fromForgotPassword = true;
        Navigator.pushNamed(context, "/setpin");
        // _changePass();
      } else {
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
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
                      "Forgot Pin",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Registered Email Id",
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

  signin() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(ctx!, listen: false);
    LoginReq loginreq = LoginReq();

    AppUtils.getStringPreferences('emailId').then((value) {
      if (value != null) {
        loginreq.email = value;
        loginreq.loginpin = codeVerifyField;
        loginreq.token = Strings.fcmToken;
        // print(loginreq.email);
        // print(loginreq.loginpin);
        //Navigator.pushNamed(ctx, "/dashboard");

        var dat = jsonEncode(loginreq);

        print(dat);

        api.login(loginreq).then((response) {
          AppUtils.dismissprogress();
          print('verifyPinResponse status ${response.toJson()}');
          assignroles() {
            if (response.data?.role == "ADMIN") {
              Strings.roleId = 1;
            } else if (response.data?.role == "STAFF") {
              Strings.roleId = 2;
            } else if (response.data?.role == "VENDOR") {
              Strings.roleId = 3;
            } else if (response.data?.role == "CONSULTANTS") {
              Strings.roleId = 4;
            } else if (response.data?.role == "CONTRACTORS") {
              Strings.roleId = 5;
            } else if (response.data?.role == "CLIENT") {
              Strings.roleId = 6;
            } else if (response.data?.role == "PUBLICUSER") {
              Strings.roleId = 7;
            }
          }

          if (response.status!) 
          {
            AppUtils.savePreferences("emailId", response.data!.emailId);
            AppUtils.savePreferences("userId", response.data!.userId);
            AppUtils.savePreferences("username", response.data!.name);
            if (response.data!.userImg != null) 
            {
              AppUtils.savePreferences("profilePic", response.data!.userImg);
              Strings.profilePic = response.data!.userImg!;
            } else 
            {
              AppUtils.savePreferences("profilePic", "");
              Strings.profilePic = "";
            }
            Strings.userID = response.data!.userId;
            Strings.authToken = response.token!;
            Strings.username = response.data!.name;
            Strings.userID = response.data!.userId;
            assignroles();
            AppUtils.savePreferences("easyAccess", "Y");
            Strings.isLogin = true;
            if (Strings.FromNotification) 
            {
              Strings.FromNotification = false;
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Attendance()));
            } else if (Strings.fromNotificationComments) 
            {
              if (Strings.selectedProDocument[0].commentId == null) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Comments()));
              } else {
                // Navigator.of(context)
                    // .push(MaterialPageRoute(builder: (context) => Replies()));
              }
            } else if(Strings.fromNotificationDocuments)
            {
              Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => ViewDocScreen()));
            }
            
            
            else 
            {
              if(Strings.roleId == 6)
              {
                Navigator.pushNamed(context, "/projects");
              }
              else
              {
                Navigator.pushNamed(ctx!, "/teamsDashboard");
              }
            }
          } else 
          {
            AppUtils.showToastError(response.message!);
          }
        }).catchError((onError) {
          AppUtils.dismissprogress();
          print(onError.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return false;
      },
      child: Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: Scaffold(body: Builder(builder: (BuildContext newContext) {
          ctx = newContext;
          return Stack(
            children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * .35,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              image: new DecorationImage(
                image: new AssetImage("assets/images/logo.jpg"),
                fit: BoxFit.fill,
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
          Container(
            margin: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * .22, 20, 10),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 54,
                  ),
                  Text(
                    "Verify Pin",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Enter your 4 digit secret pin",
                    style: TextStyle(color: const Color(0xFF9e9e9e)),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  _boxBuilder(),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _forgotPass();
              //AppUtils.clearAllPreferences();
              //  Navigator.popAndPushNamed(context, '/login');
            },
            child: Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(
                    10, MediaQuery.of(context).size.height * .68, 10, 20),
                child: Text("Forgot Pin",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9e9e9e)))),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(
                10, MediaQuery.of(context).size.height * .75, 10, 20),
            child: ButtonTheme(
              minWidth: double.infinity,
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(15),
                  onPressed: () {
                    print(
                        "${oneT.text} ${twoT.text} ${threeT.text} ${fourT.text}");
                    codeVerifyField =
                        oneT.text + twoT.text + threeT.text + fourT.text;
                    print(codeVerifyField);
                    print("${codeVerifyField!.length}");
                    if (codeVerifyField!.length < 4) {
                      AppUtils.showToastError("Please Enter Pin");
                    } else {
                      signin();
                    }
                  },
                  child: Text("SUBMIT",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white)),
                  color: Color(0xFF0061b0)),
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not ${Strings.username}?",
                    style: TextStyle(color: const Color(0xFF9e9e9e)),
                  ),
                  TextButton(
                      onPressed: () {
                        AppUtils.savePreferences("easyAccess", "N");
                        AppUtils.removeDeviceId(context);
                        Navigator.popAndPushNamed(context, "/login");
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ))
                ],
              ),
            ),
          )
            ],
          );
        })),
      ),
    );
  }

  Widget _boxBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _box(1),
        _box(2),
        _box(3),
        _box(4),
      ],
    );
  }

  Widget _boxBuilder1(contextResetPin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _box1(1, contextResetPin),
        _box1(2, contextResetPin),
        _box1(3, contextResetPin),
        _box1(4, contextResetPin),
        _box1(5, contextResetPin),
      ],
    );
  }

  Widget _box1(val, contextResetPin) {
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
              ? ResetoneT
              : val == 2
                  ? ResettwoT
                  : val == 3
                      ? ResetthreeT
                      : val == 4
                          ? ResetfourT
                          : ResetfiveT,
          focusNode: val == 1
              ? Resetone
              : val == 2
                  ? Resettwo
                  : val == 3
                      ? Resetthree
                      : val == 4
                          ? Resetfour
                          : Resetfive,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10), counterText: ''),
          textAlign: TextAlign.center,
          onChanged: (value) {
            print(value);

            if (value == '') {
              FocusScope.of(contextResetPin).requestFocus(
                val == 5
                    ? Resetfour
                    : val == 4
                        ? Resetthree
                        : val == 3
                            ? Resettwo
                            : val == 2
                                ? Resetone
                                : null,
              );
            } else {
              FocusScope.of(contextResetPin).requestFocus(
                val == 1
                    ? Resettwo
                    : val == 2
                        ? Resetthree
                        : val == 3
                            ? Resetfour
                            : val == 4
                                ? Resetfive
                                : null,
              );
              print("not null");
            }
          },
        ),
      ),
    );
  }

  Widget _box(val) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        alignment: Alignment.center,
        height: 50,
        width: 40,
        child: TextField(
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}'))
          ],
          maxLength: 1,
          autofocus: true,
          controller: val == 1
              ? oneT
              : val == 2
                  ? twoT
                  : val == 3
                      ? threeT
                      : fourT,
          focusNode: val == 1
              ? one
              : val == 2
                  ? two
                  : val == 3
                      ? three
                      : four,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10), counterText: ''),
          textAlign: TextAlign.center,
          onChanged: (value) {
            print(value);
            if (value == '') {
              FocusScope.of(context).requestFocus(
                val == 4
                    ? three
                    : val == 3
                        ? two
                        : val == 2
                            ? one
                            : null,
              );
            } else {
              FocusScope.of(context).requestFocus(
                val == 1
                    ? two
                    : val == 2
                        ? three
                        : val == 3
                            ? four
                            : null,
              );
              print("not null");
            }
            codeVerifyField = oneT.text + twoT.text + threeT.text + fourT.text;
            print("qwe  ${codeVerifyField?.length}");
            if (codeVerifyField!.length == 4) {
              FocusManager.instance.primaryFocus?.unfocus();
              signin();
            }
          },
        ),
      ),
    );
  }
}
