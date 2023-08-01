import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
   final Widget mobile;
   final Widget tablet;
   final Widget tv;

   const Responsive({
      Key? key,
      required this.mobile,
      required this.tablet,
      required this.tv,
   }) : super(key: key);

   static bool isMobile(BuildContext context) {
      var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      return MediaQuery.of(context).size.width < 650 && isPortrait ||
            MediaQuery.of(context).size.height < 650 && !isPortrait;
   }

   static bool isTablet(BuildContext context) {
      var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      return MediaQuery.of(context).size.width < 1300 &&
                  isPortrait &&
                  MediaQuery.of(context).size.width >= 650 &&
                  isPortrait ||
            MediaQuery.of(context).size.height < 1300 &&
                  !isPortrait &&
                  MediaQuery.of(context).size.height >= 650 &&
                  !isPortrait;
   }

   static bool isTv(BuildContext context) =>
         MediaQuery.of(context).size.width >= 1100;

   @override
   Widget build(BuildContext context) {
      return LayoutBuilder(
         builder: (context, constraints) {
            if (constraints.maxWidth >= 1100) {
               return tv;
            } else if (constraints.maxWidth >= 650) {
               return tablet;
            } else {
               return mobile;
            }
         },
      );
   }
}