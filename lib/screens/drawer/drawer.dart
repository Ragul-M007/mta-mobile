import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/drawer";
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  FancyDrawerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child:

            // Container(color: Colors.red, ),
            //

            Container(
      decoration: BoxDecoration(
        color: Colors.red,
        // image: new DecorationImage(
        //   image: new AssetImage("assets/images/background1.png"),
        //   fit: BoxFit.fill,
        // )
      ),
      child: FancyDrawerWrapper(
        backgroundColor: Colors.transparent,
        controller: _controller,
        drawerItems: <Widget>[
          Container(
            child: Row(
              children: [
                Icon(Icons.ac_unit, color: Colors.white),
                Text("MTA Architects")
              ],
            ),
          ),
          InkWell(
            onTap: () {
              print("object");
              menuRedirect("1");
            },
            child: Container(
              width: double.infinity,
              child: Text(
                "Projects",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            child: InkWell(
              onTap: menuRedirect("2"),
              child: Text(
                "Attendance",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Text(
            "Profile",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Notification",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            child: InkWell(
              child: Text(
                "Contact us",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Text(
            "Privacy Policy",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "News & Highlights",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Logout",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            elevation: 4.0,
            title: Text(
              "Some appbar",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                _controller.toggle();
              },
            ),
          ),
          body: Center(
            child: Text("Body"),
          ),
        ),
      ),
    ));
  }

  menuRedirect(option) {
    print(option);
    if (option == "2") {
      Navigator.pushNamed(context, "/attendance");
    }
  }
}
