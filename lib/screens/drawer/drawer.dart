import 'package:flutter/material.dart';
import 'package:mta/utilities/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/drawer";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          elevation: 4.0,
          title: const Text(
            "MTA Konnect",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("Home"),
        ),
      ),
    );
  }
}
