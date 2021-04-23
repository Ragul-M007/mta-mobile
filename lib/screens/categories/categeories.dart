import 'package:flutter/material.dart';
import 'package:mta/models/FetchCatsRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

class Categories extends StatelessWidget {
  const Categories({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: appbar("Project Details"),
        body: CategoriesContent(),
      ),
    );
  }
}

class CategoriesContent extends StatefulWidget {
  static const String routeName = "/categories";

  @override
  _CategoriesContentState createState() => _CategoriesContentState();
}

class _CategoriesContentState extends State<CategoriesContent> {
  List<FectchCatsData> _catsList = [];
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: new DecorationImage(
                    image: new NetworkImage(Strings.baseImageUrl +
                        Strings.selectedProject[0].projectImg),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  Strings.category = false;
                  Navigator.pushNamed(context, '/viewdoclist');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          Strings.selectedProject[0].projectName,
                          style: Drawables.adddoccontentstyle(
                              Colors.black, 15.0, FontWeight.w500),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.info_outlined,
                          size: 15,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 15.0,
                          height: 15.0,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: new AssetImage("assets/icons/pin.png"),
                              fit: BoxFit.fill,
                            ),
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(50.0)),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          Strings.selectedProject[0].address +
                              ' , ' +
                              Strings.selectedProject[0].city,
                          style: Drawables.adddoccontentstyle(
                              Colors.grey, 13.0, FontWeight.normal),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemBuilder: (BuildContext ctx, int index) {
              return _catsList != null
                  ? Padding(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          Strings.selectedCategory = [];
                          Strings.selectedCategory.add(_catsList[index]);
                          Strings.category = true;
                          Navigator.pushNamed(context, '/viewdoclist');
                        },
                        child: Container(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(_catsList[index].categoryName,
                                          style: Drawables.adddoccontentstyle(
                                              Colors.black87,
                                              14.0,
                                              FontWeight.w500))),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 14.0,
                                  )
                                ],
                              )),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox();
              // return Text("hi");
            },
            itemCount: _catsList.length,
          ),
        )
      ],
    );
  }

  getCategories() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.getCats(Strings.selectedProject[0].projectId).then((response) {
      AppUtils.dismissprogress();
      print('categoiresResponse status ${response.toJson()}');
      if (response.status) {
        setState(() {
          _catsList = response.data;
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
}
