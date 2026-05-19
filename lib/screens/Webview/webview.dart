import 'package:flutter/material.dart';
import 'package:mta/utilities/app_drawer.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

FocusNode name = new FocusNode();
ImagePicker _picker = ImagePicker();
WebViewController controller = WebViewController();

class WebpageView extends StatefulWidget {
  static const String routeName = "/webview";

  @override
  _WebpageViewState createState() => _WebpageViewState();
}

class _WebpageViewState extends State<WebpageView> {
  @override
  void initState() {
    super.initState();

    configureWebview();
  }

  configureWebview() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            AppUtils.dismissprogress();
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse('https://www.mtaarch.com/'));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(child: LoginContent());

    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Scaffold(
        drawer: AppDrawer(),
        backgroundColor: const Color(0xFFececed),
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 20, 5),
                child: GestureDetector(
                    onTap: () {
                      print(Strings.baseImageUrl + Strings.profilePic!);
                      _showMyDialog(
                          context,
                          Strings.baseImageUrl + Strings.profilePic!,
                          Strings.username);
                    },
                    child: CircleAvatar(
                      backgroundImage: (Strings.profilePic != "")
                          ? NetworkImage(
                              Strings.baseImageUrl + (Strings.profilePic ?? ""))
                          : AssetImage(
                              "assets/icons/account.png",
                            ) as ImageProvider,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                    )
                    // Strings.profilePic == null
                    //     ? Image.asset(
                    //         "assets/images/user.png",
                    //         height: 40,
                    //         width: 40,
                    //       )
                    //     : Image.network(
                    //         Strings.baseImageUrl + Strings.profilePic!,
                    //         height: 40,
                    //         width: 40,
                    //       ),
                    // image.(
                    //     Strings.baseImageUrl + Strings.profilePic!,
                    //     40.0,
                    //     40.0),
                    ))
          ],
          leading: Builder(
            builder: (ctx) => SizedBox(
              height: 25.0,
              width: 25.0,
              child: IconButton(
                icon: Icon(
                  Icons.menu,
                  size: 25.0,
                  color: const Color(0xFF979797),
                ),
                onPressed: () {
                  Scaffold.of(ctx).openDrawer();
                },
              ),
            ),
          ),
        ),
        body: ProfileContent(),
      ),
    );
  }

  menuRedirect({@required String? routename, int? currentmenu}) {
    setState(() {
      Strings.currentmenuvalue = currentmenu!;
    });
    if (routename == "/login") {
      //AppUtils.clearAllPreferences();
      //Navigator.pop(context);
      //Navigator.popAndPushNamed(context, routename);
      Strings.isLogin = false;
      Navigator.popAndPushNamed(context, "/login");
    } else {
      //Navigator.pop(context);
      Navigator.pushNamed(context, routename!);
    }
  }
}

class ProfileContent extends StatefulWidget {
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

Future<void> _showMyDialog(context, imgurl, title) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                // height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    new Icon(Icons.close, size: 22.0, color: Colors.black),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF0061b0),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: (Strings.profilePic != "")
                            ? NetworkImage(Strings.baseImageUrl +
                                (Strings.profilePic ?? ""))
                            : AssetImage("assets/icons/account.png")
                                as ImageProvider,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                      ),
                    )
                  ],
                ),
                // decoration: new BoxDecoration(
                //   color: Colors.transparent,
                //   image: new DecorationImage(
                //     image: new NetworkImage(imgurl),
                //     fit: BoxFit.contain,
                //   ),
                //   borderRadius:
                //       new BorderRadius.all(new Radius.circular(10.0)),
                // ),
              )),
        ),
      );
    },
  );
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  void initState() {
    super.initState();
    AppUtils.showprogress();

    // WidgetsBinding.instance.addPostFrameCallback((_) => getProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: WebViewWidget(controller: controller));
  }
}
