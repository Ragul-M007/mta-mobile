import 'package:flutter/material.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/ProfileRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  static const String routeName = "/profile";

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    // return Container(child: LoginContent());

    return Scaffold(
        //appBar: EmptyAppBar(),
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Provider<ApiService>(
          create: (context) => ApiService.create(), child: ProfileContent()),
    ));
    // child: Scaffold(appBar: EmptyAppBar(), body: LoginContent())));
  }
}

class ProfileContent extends StatefulWidget {
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

// class Profile extends StatefulWidget {
//   static const String routeName = "/profile";

//   @override
//   _ProfileState createState() => _ProfileState();
// }

class _ProfileContentState extends State<ProfileContent> {
  final mobileField = TextEditingController();
  final userType = TextEditingController();
  final password = TextEditingController();

  ProfileRes _profileData;

  @override
  void initState() {
    mobileField.text = "";
    userType.text = "";
    password.text = "123456";
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * .32,
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.yellow,
                    child: Icon(
                      Icons.accessibility_outlined,
                    ),
                    radius: 25,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profileData.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        _profileData.emailId,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
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
                Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Profile",
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
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Padding(
              padding: EdgeInsets.all(30),
              child: Row(
                children: [
                  Icon(Icons.pin_drop),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    "G.R.G. Layout, Trichy Rd, Coimbatore, \nTamil Nadu 641018",
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
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: mobileField,
                  decoration: InputDecoration(prefixIcon: Icon(Icons.call)),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "User Type",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: userType,
                  decoration: InputDecoration(prefixIcon: Icon(Icons.person)),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Password",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: password,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key),
                      suffixText: "Change Password",
                      suffixStyle: TextStyle(color: Colors.blue)),
                )
              ],
            )),
      ],
    )));
  }

  getProfile() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);

    api.profile().then((response) {
      AppUtils.dismissprogress();
      print('profileResponse status ${response.toJson()}');

      // Navigator.pushNamed(ctx, "/dashboard");
      setState(() {
        _profileData = response;
        mobileField.text = _profileData.mobileNo;
        userType.text = _profileData.role;
      });
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
}
