import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mta/models/Chat/MediaDetailsRes.dart';
import 'package:provider/provider.dart';

import '../../network/ApiService.dart';
import '../../utilities/apputilities.dart';
import '../../utilities/strings.dart';

class ChatMedia extends StatefulWidget {
  const ChatMedia({super.key, required this.groupId});

  final int groupId;


  @override
  State<ChatMedia> createState() => _ChatMediaState();
}

class _ChatMediaState extends State<ChatMedia> with TickerProviderStateMixin{
  TabController? _tabController;
  List<MediaData> _imageList = [];
  List<MediaData> _videoList = [];
  List<MediaData> _docList = [];

  String? basePath;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
        _tabController = new TabController(length: 3, vsync: this);
  findPath();
      getDocumentDetails("image");
      getDocumentDetails("document");
      getDocumentDetails("video");

      
  }

findPath() async
  {
    basePath = Strings.basePath;
  }
  getDocumentDetails(type) 
  {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.getMediaDetails(widget.groupId,type).then((response) {
      if (response.status!) 
      {
        setState(() {
          if(type == "image")
          {
                  _imageList = response.data!;
          }
          else if(type == "video")
          {
             _videoList = response.data!;
          }
          else {
            _docList = response.data!;
          }
        });
        
       
        AppUtils.dismissprogress();
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Media"),),
      body: tabbarwidget(),
    );
  }

  Widget tabbarwidget() {
    return Container(
        // padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              child: TabBar(
                tabs: [
                  Container(
                    height: 36,
                    // width: MediaQuery.of(context).size.width * 0.45,
                    child: Text('Images',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF272626))),
                  ),
                  Container(
                    height: 36,
                    child: Text('Videos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9e9e9e))),
                  ),
                  Container(
                    height: 36,
                    child: Text('Documents',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9e9e9e))),
                  )
                ],
                unselectedLabelColor: const Color(0xffacb3bf),
                indicatorColor: Color(0xFF0061b0),
                labelColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3.0,
                indicatorPadding: EdgeInsets.all(10),
                isScrollable: false,
                controller: _tabController,
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: <Widget>[
                imageViewer(),
                videoViewer(),
                documentViewer()

                //
              ]),
            )
          ],
        ));
  }


  Widget imageViewer() 
  {
    return 
    _imageList.length != 0?
         GridView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return 
              
              Container(
                margin: EdgeInsets.all(10),
                color: Colors.grey.withOpacity(0.1),
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () {
                              print("ooon   ${basePath!+"/"+ _imageList[index].filesName!+AppUtils.getFileExtension(_imageList[index].filesName!)}");
                                                 AppUtils.openFile(basePath!+"/"+ _imageList[index].filesName!+AppUtils.getFileExtension(_imageList[index].files!));
                            },
                            child: Column(
                              children: [
                                Container(
                                        width:
                                            MediaQuery.of(context).size.width * 0.4,
                                            height:MediaQuery.of(context).size.height * 0.14,
                                        child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              child: Image.file(File(basePath!+"/"+ _imageList[index].filesName!+AppUtils.getFileExtension(_imageList[index].files!))),
                                
                                        ))),
                                        SizedBox(height: 16,),
                                        Text(
                                        _imageList[index].fileOriginalName ?? "",
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),

                              ],
                            ),
                          )));
            },
            itemCount: _imageList.length, 
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          ):SizedBox();
  }

  Widget videoViewer() 
  {
    return 
    _videoList.length != 0?
         ListView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return Container(
                margin: EdgeInsets.all(10),
                color: Colors.grey.withOpacity(0.1),
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () {
                              print("ooon ${Strings.uatImageUrl + _videoList[index].files!}");
                                                 AppUtils.openFile(basePath!+"/"+ _videoList[index].filesName!+AppUtils.getFileExtension(_videoList[index].files!));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.ltr,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: 80,
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: Text("video")
        //                                   VTImageView(
        //   videoUrl:
        //       Strings.uatImageUrl + _videoList[index].files!,
        //   width: 200.0,
        //   height: 200.0,
        //   errorBuilder: (context, error, stack) {
        //     return Container(
        //       width: 200.0,
        //       height: 200.0,
        //       color: Colors.blue,
        //       child: Center(
        //         child: Text("Image Loading Error"),
        //       ),
        //     );
        //   }, assetPlaceHolder: 'No Image',
        // ),
                                        //  Image.file(File(basePath!+"/"+ _videoList[index].filesName!+AppUtils.getFileExtension(_videoList[index].files!))),

                                    ))),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _videoList[index].fileOriginalName ?? "",
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                      "${  ((double.parse(_videoList[index].fileSize!) / 1028)/1024).toStringAsFixed(2)} MB" ,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 18.0,
                                            height: 18.0,
                                            child: IconButton(
                                              padding: new EdgeInsets.all(0.0),
                                              color: Colors.grey,
                                              icon: new Icon(Icons.lock_clock,
                                                  size: 18.0),
                                              onPressed: () {},
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                          _videoList[index].createdAt ?? "",
                                            textAlign: TextAlign.left,
                                            textDirection: TextDirection.ltr,
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )));
            },
            itemCount: _videoList.length,
          ):SizedBox();
  }

   Widget documentViewer() 
  {
    return 
    _docList.length != 0?
         ListView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return Container(
                margin: EdgeInsets.all(10),
                color: Colors.grey.withOpacity(0.1),
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () {
                              print("ooon   ${basePath!+"/"+ _docList[index].filesName!+AppUtils.getFileExtension(_docList[index].filesName!)}");
                                                 AppUtils.openFile(basePath!+"/"+ _docList[index].filesName!+AppUtils.getFileExtension(_docList[index].files!));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.ltr,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.25,
                                    height: 80,
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: 
                                          
                                          Image.asset(AppUtils.getFilTypeImg(_docList[index].files))),

                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _docList[index].fileOriginalName ?? "",
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                      "${  ((double.parse(_docList[index].fileSize!) / 1028)/1024).toStringAsFixed(2)} MB" ,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 18.0,
                                            height: 18.0,
                                            child: IconButton(
                                              padding: new EdgeInsets.all(0.0),
                                              color: Colors.grey,
                                              icon: new Icon(Icons.lock_clock,
                                                  size: 18.0),
                                              onPressed: () {},
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                          _docList[index].createdAt ?? "",
                                            textAlign: TextAlign.left,
                                            textDirection: TextDirection.ltr,
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )));
            },
            itemCount: _docList.length,
          ):SizedBox();
  }
}

