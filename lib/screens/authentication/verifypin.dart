import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/SetPinReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mta/screens/attendance/attendance.dart';

class Verifypin extends StatefulWidget {
  static const String routeName = "/verifypin";

  @override
  _VerifypinState createState() => _VerifypinState();
}

class _VerifypinState extends State<Verifypin> {
  final mobileField = TextEditingController();
  String? codeVerifyField;
  String? verificationCode;

  bool _isLoading = false;

  FocusNode one = new FocusNode();
  FocusNode two = new FocusNode();
  FocusNode three = new FocusNode();
  FocusNode four = new FocusNode();

  final oneT = TextEditingController();
  final twoT = TextEditingController();
  final threeT = TextEditingController();
  final fourT = TextEditingController();

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
        api.login(loginreq).then((response) {
          AppUtils.dismissprogress();
          print('verifyPinResponse status ${response.toJson()}');
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
            AppUtils.savePreferences("emailId", response.data!.emailId);
            AppUtils.savePreferences("userId", response.data!.userId);
            if (response.data!.userImg != null) {
              AppUtils.savePreferences("profilePic", response.data!.userImg);
              Strings.profilePic = response.data!.userImg!;
            } else {
              AppUtils.savePreferences("profilePic", "");
              Strings.profilePic = "";
            }
            Strings.userID = response.data!.userId;
            Strings.authToken = response.token!;
            Strings.username = response.data!.name;
            assignroles();
            AppUtils.savePreferences("easyAccess", "Y");
            Strings.isLogin = true;
            if(Strings.FromNotification)
            {
                Strings.FromNotification = false;
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Attendance()));
            }
            else
            {
                Navigator.pushNamed(ctx!, "/dashboard");
            }

          } else {
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
      onWillPop: () async 
      {
        _onWillPop();
        return false;
      },
      child: Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: Scaffold(body: Builder(builder: (BuildContext newContext) {
          ctx = newContext;
          return SafeArea(
              child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * .35,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: new DecorationImage(
                    image: new AssetImage("assets/images/background1.png"),
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
                  //AppUtils.clearAllPreferences();
                  Navigator.popAndPushNamed(context, '/login');
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
            ],
          ));
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

  Widget _box(val) 
  {
    return Padding(
      padding: EdgeInsets.all(1),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        alignment: Alignment.center,
        height: 50,
        width: 40,
        child: TextField(
          keyboardType: TextInputType.numberWithOptions(signed: true,decimal:true),
          textInputAction: TextInputAction.done,          
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}'))],
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
          },
        ),
      ),
    );
  }
}
