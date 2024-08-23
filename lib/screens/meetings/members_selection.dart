// import 'dart:developer';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mta/models/AddMeetingReq.dart';
// import 'package:mta/network/ApiService.dart';
// import 'package:mta/utilities/drawables.dart';
// import 'package:mta/utilities/strings.dart';
// import 'package:provider/provider.dart';

// class MembersSelection extends StatefulWidget {
//   AddMeetingReq addMeetingReq;
//   MembersSelection({super.key, required this.addMeetingReq});

//   @override
//   State<MembersSelection> createState() => _MembersSelectionState();
// }

// class _MembersSelectionState extends State<MembersSelection> {
//   BuildContext? ctx;

//   @override
//   void initState() {
//     super.initState();
//     getTeamsUsers();
//   }

//   getTeamsUsers() {
//     log(">>>>>:${Strings.authToken}");
//     // AppUtils.showprogress();
//     // if (teamUsersLists.isEmpty) {
//     //   final api = Provider.of<ApiService>(context, listen: false);

//     //   api.fetchTeams().then((response) {
//     //     // AppUtils.dismissprogress();
//     //     if (response.status!) {
//     //       teamLists = response.data!;
//     //     }
//     //     getProjects();
//     //   }).catchError((onError) {
//     //     // AppUtils.dismissprogress();
//     //     print(onError.toString());
//     //     //getProjects();
//     //   });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Provider<ApiService>(
//         create: (context) => ApiService.create(),
//         child: Scaffold(
//           resizeToAvoidBottomInset: false,
//           body: Builder(builder: (BuildContext newContext) {
//             return membersSelectionWidget(newContext);
//           }),
//         ));
//   }

//   membersSelectionWidget(BuildContext context) {
//     ctx = context;
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         child: Container(
//           decoration: BoxDecoration(
//               borderRadius:
//                   BorderRadius.only(bottomLeft: Radius.circular(30.0)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey,
//                   offset: Offset(0.1, 1.0),
//                   blurRadius: 6.0,
//                 ),
//               ]),
//           child: AppBar(
//             iconTheme: IconThemeData(color: Colors.black),
//             shape: RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.only(bottomLeft: Radius.circular(30.0))),
//             elevation: 0,
//             title: Text(
//               "Select members",
//               style: Drawables.adddoccontentstyle(
//                   Colors.black, 16.0, FontWeight.bold),
//             ),
//             leading: SizedBox(
//                 height: 25.0,
//                 width: 25.0,
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.arrow_back,
//                     size: 25.0,
//                     color: const Color(0xFF979797),
//                   ),
//                   onPressed: () {},
//                 )),
//           ),
//         ),
//         preferredSize: Size.fromHeight(kToolbarHeight),
//       ),
//       body: Column(),
//     );
//   }
// }
