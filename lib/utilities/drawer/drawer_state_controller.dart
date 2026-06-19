import 'package:mta/utilities/strings.dart';

class DrawerMenuEntry {
  const DrawerMenuEntry({
    required this.id,
    required this.title,
    required this.routeName,
    this.requiresLogoutConfirmation = false,
    this.beforeNavigate,
  });

  final int id;
  final String title;
  final String routeName;
  final bool requiresLogoutConfirmation;
  final void Function()? beforeNavigate;
}

class DrawerStateController {
  const DrawerStateController();

  int get selectedMenuId => Strings.currentmenuvalue;

  bool isSelected(int menuId) => selectedMenuId == menuId;

  List<DrawerMenuEntry> buildMenuEntries() {
    return <DrawerMenuEntry>[
      DrawerMenuEntry(
        id: 3,
        title: 'Projects',
        routeName: '/projects',
        beforeNavigate: () => Strings.fromProjects = true,
      ),
      const DrawerMenuEntry(
        id: 2,
        title: 'Meetings',
        routeName: '/meetings',
      ),
      const DrawerMenuEntry(
        id: 4,
        title: 'Attendance',
        routeName: '/attendance',
      ),
      const DrawerMenuEntry(
        id: 5,
        title: 'Profile',
        routeName: '/profile',
      ),
      const DrawerMenuEntry(
        id: 6,
        title: 'Notification',
        routeName: '/notification',
      ),
      const DrawerMenuEntry(
        id: 7,
        title: 'Contact Us',
        routeName: '/contactus',
      ),
      const DrawerMenuEntry(
        id: 8,
        title: 'News & Highlights',
        routeName: '/newshighlights',
      ),
      const DrawerMenuEntry(
        id: 9,
        title: 'Logout',
        routeName: '/login',
        requiresLogoutConfirmation: true,
      ),
    ];
  }
}

