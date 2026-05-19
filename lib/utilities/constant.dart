import 'package:flutter/material.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';

Widget menuoption({
  @required void Function()? ontab,
  @required selectedmenuvalue,
  @required String? menutitle,
}) {
  return GestureDetector(
    onTap: ontab,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Strings.currentmenuvalue == selectedmenuvalue
            ? const Color(0XFF1c72b9)
            : Colors.transparent,
      ),
      padding: EdgeInsets.fromLTRB(30, 16, 0, 16),
      child: Text(
        menutitle!,
        style: TextStyle(
          fontSize: 17,
          color: Strings.currentmenuvalue == selectedmenuvalue
              ? Colors.white
              : const Color(0xFF519bd7),
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

PreferredSizeWidget appbar(String title) {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.black),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0))),
    elevation: 8,
    title: Text(
      title,
      style: Drawables.adddoccontentstyle(Colors.black, 16.0, FontWeight.bold),
    ),
    actions: [
      // title == "Documents"
      //     ? Padding(
      //         padding: const EdgeInsets.only(right: 20),
      //         child: Icon(
      //           Icons.search,
      //           color: Colors.black,
      //         ),
      //       )
      //     :
      Padding(padding: EdgeInsets.all(0))
    ],
  );
}

PreferredSizeWidget mainappbar(
    {@required Function? ontab, @required String? title}) {
  return AppBar(
    iconTheme: const IconThemeData(color: Colors.black),
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0))),
    elevation: 3,
    title: Text(
      title!,
      style: Drawables.adddoccontentstyle(Colors.black, 16.0, FontWeight.bold),
    ),
    leading: Builder(
      builder: (context) => SizedBox(
        height: 25.0,
        width: 25.0,
        child: IconButton(
          icon: const Icon(
            Icons.menu,
            size: 25.0,
            color: Color(0xFF979797),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    ),
  );
}

Widget button(
    {@required VoidCallback? ontab, @required String? buttoncontent}) {
  return GestureDetector(
    onTap: ontab,
    child: Container(
      child: Center(
          child: Text(
        buttoncontent!,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
        textAlign: TextAlign.center,
      )),
      width: double.infinity,
      height: 40,
      margin: EdgeInsets.fromLTRB(10, 25, 20, 2),
      decoration: BoxDecoration(
          color: Color(0xFF0061b0), borderRadius: BorderRadius.circular(25)),
    ),
  );
}
