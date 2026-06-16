import 'package:flutter/material.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  void _menuRedirect(BuildContext context,
      {required String routename, int currentmenu = 1}) {
    Strings.currentmenuvalue = currentmenu;
    Navigator.of(context).pop(); // close drawer first
    if (routename == "/login") {
      AppUtils.savePreferences("easyAccess", "N");
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } else {
      final currentRouteName = ModalRoute.of(context)?.settings.name;
      if (currentRouteName == routename) {
        return;
      }
      Navigator.pushReplacementNamed(context, routename);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration:
            Drawables.menudecorationImage("assets/images/Menubg.png", 0.0),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Row(
                  children: [
                    Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: Drawables.menudecorationImage(
                          "assets/images/logo.jpg", 50.0),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "MTA Konnect",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
              if (Strings.roleId != 6)
                menuoption(
                  ontab: () {
                    Strings.fromProjects = false;
                    _menuRedirect(context,
                        routename: "/teamsDashboard", currentmenu: 1);
                  },
                  selectedmenuvalue: 1,
                  menutitle: Strings.roleId == 7 ? "Home" : "Teams",
                ),
              menuoption(
                ontab: () => _menuRedirect(context,
                    routename: "/meetings", currentmenu: 2),
                selectedmenuvalue: 2,
                menutitle: "Meetings",
              ),
              if (Strings.roleId != 7)
                menuoption(
                  ontab: () {
                    Strings.fromProjects = true;
                    _menuRedirect(context,
                        routename: "/projects", currentmenu: 3);
                  },
                  selectedmenuvalue: 3,
                  menutitle: "Projects",
                ),
              if (Strings.roleId == 1 ||
                  Strings.roleId == 2 ||
                  Strings.roleId == 5)
                menuoption(
                  ontab: () => _menuRedirect(context,
                      routename: "/attendance", currentmenu: 4),
                  selectedmenuvalue: 4,
                  menutitle: "Attendance",
                ),
              menuoption(
                ontab: () => _menuRedirect(context,
                    routename: "/profile", currentmenu: 5),
                selectedmenuvalue: 5,
                menutitle: "Profile",
              ),
              menuoption(
                ontab: () => _menuRedirect(context,
                    routename: "/notification", currentmenu: 6),
                selectedmenuvalue: 6,
                menutitle: "Notification",
              ),
              menuoption(
                ontab: () => _menuRedirect(context,
                    routename: "/contactus", currentmenu: 7),
                selectedmenuvalue: 7,
                menutitle: "Contact Us",
              ),
              menuoption(
                ontab: () => _menuRedirect(context,
                    routename: "/newshighlights", currentmenu: 8),
                selectedmenuvalue: 8,
                menutitle: "News & Highlights",
              ),
              menuoption(
                ontab: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(
                        "Are you sure ?",
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF0061b0),
                            fontWeight: FontWeight.w600),
                      ),
                      content: const Text(
                        'Do you want to logout from the App',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'No',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            AppUtils.removeDeviceId(context);
                            _menuRedirect(context,
                                routename: "/login", currentmenu: 9);
                          },
                          child: const Text(
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
          ),
        ),
      ),
    );
  }
}
