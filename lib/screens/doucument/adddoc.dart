import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mta/models/AddDocReq.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/UserAccessreq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mta/utilities/strings.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'dart:io' as Io;

import 'package:provider/provider.dart';

List<FetchMapedUsersData> users = Strings.users;
var _userIitems = users
    .map((user) => MultiSelectItem<FetchMapedUsersData?>(user, user.name!))
    .toList();


 List<FetchMapedUsersData?> selectedUsers = <FetchMapedUsersData>[];
  String selectedUser = "";


class AddDoc extends StatelessWidget {
  const AddDoc({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(30.0))),
            elevation: 8,
            title: Text("Add Document",
                style: Drawables.adddoccontentstyle(
                    Colors.black, 16.0, FontWeight.bold)),
          ),
          body: AddDocContent(),
        ),
      ),
    );
  }
}

class AddDocContent extends StatefulWidget {
  static const String routeName = "/adddoc";

  @override
  _AddDocContentState createState() => _AddDocContentState();
}

class _AddDocContentState extends State<AddDocContent> 
{
  TextEditingController docTitle = TextEditingController();
  TextEditingController docDesc = TextEditingController();
  String file64 = '';
  String? fileExt;

  
  getUserCats() 
  {
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchUsers(Strings.selectedProject[0].projectId!).then((response) {
      if (response.status!) 
      {
        setState(() {
          Strings.users = response.data!;
          users = response.data!;
          _userIitems = users
    .map((user) => MultiSelectItem<FetchMapedUsersData?>(user, user.name!))
    .toList();
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
  void initState() {
    super.initState();
    getUserCats();
  }

  @override
  Widget build(BuildContext context) {
    print("Usrs count--> ${users.length}");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, bottom: 20),
              child: Row(
                children: [
                  Text(
                    "Upload File",
                    style: Drawables.adddoccontentstyle(
                        Colors.black87, 15.0, FontWeight.bold),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  uploadButton(),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 15.0),
              child: Text(
                "Document Title",
                style: Drawables.adddoccontentstyle(
                    Colors.black45, 14.0, FontWeight.w400),
              ),
            ),
            Container(
                height: 40.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40.0)),
                child: TextField(
                  controller: docTitle,
                  style: TextStyle(
                      color: Color(0xff151515), fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Name",
                    hintStyle: Drawables.adddoccontentstyle(
                        Colors.grey, 12.0, FontWeight.w400),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    counterText: "",
                    contentPadding: EdgeInsets.only(left: 15, top: 9.0),
                  ),
                  keyboardType: TextInputType.text,
                )),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: MultiSelectDialogField<FetchMapedUsersData?>(
                      items: _userIitems,
                      title: Text("Select Users"),
                      selectedColor: Color(0xFF0061b0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        border: Border.all(
                          color: Color(0xFF0061b0),
                          width: 2,
                        ),
                      ),
                      buttonIcon: Icon(
                        Icons.person,
                        color: Color(0xFF0061b0),
                      ),
                      buttonText: Text(
                        "Tag Users",
                        style: TextStyle(
                          color: Color(0xFF0061b0).withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                      onConfirm: (results) 
                      {
                        selectedUser = "";
                        selectedUsers = results;

                        //selectedUsers.addall(results);
                        print("data--> ${results[0]}");
                          var data = jsonEncode(results);
                        print("Check $data");
                        if (results.length > 0) 
                        {
                         selectedUsers.forEach((element) 
                          {
                            
                            selectedUser += '${element?.userId},';
                            // tagedUsers.add(element.name);
                            // tagedUsersId.add(element.userId);
                          });

                        } else {
                           // tagedUsers = [];
                           // tagedUsersId = [];
                         }
                      },
                    ),
                ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 15.0),
              child: Text(
                "Description",
                style: Drawables.adddoccontentstyle(
                    Colors.black45, 14.0, FontWeight.w400),
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0)),
                child: TextFormField(
                  controller: docDesc,
                  maxLines: 6,
                  style: TextStyle(
                      color: Color(0xff151515), fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Type here..",
                    hintStyle: Drawables.adddoccontentstyle(
                        Colors.grey, 12.0, FontWeight.w400),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    counterText: "",
                    contentPadding: EdgeInsets.only(left: 15, top: 9.0),
                  ),
                  keyboardType: TextInputType.text,
                )),
            SizedBox(
              height: 15,
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: button(ontab: submit, buttoncontent: "SUBMIT"))
          ],
        ),
      ),
    );
  }
  UpdateRights()
  {
    String users = "";
    if (selectedUser.length > 0) 
    {
        users = selectedUser.substring(0, selectedUser.length - 1);
    }
    UserAccessReq userAccessReq = UserAccessReq();
    userAccessReq.projectId = Strings.selectedProject[0].projectId;
    userAccessReq.userId = users;
    userAccessReq.document = Strings.docID;
    var test = jsonEncode(userAccessReq);
    print("user--> $test");

    final api = Provider.of<ApiService>(context, listen: false);
    api.userAccess(users,userAccessReq,).then((response) 
      {

        print(response.message);
        if (response.status!) {
        } else {
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        print(onError.toString());
      });
  }

  Widget uploadButton() {
    return GestureDetector(
      onTap: () async 
      {
        // FilePickerResult result = await FilePicker.platform.pickFiles(
        //   type: FileType.custom,
        //   allowedExtensions: [
        //     'jpg',
        //     'pdf',
        //     'doc',
        //     'jepg',
        //     'png',
        //     'xlsx',
        //     'docx',
        //     'xls'
        //   ],
        // );
        FilePickerResult? result = await FilePicker.pickFiles();
        if (result != null) 
        {
          PlatformFile file = result.files.first;
          final bytes = await Io.File(file.path!).readAsBytes();
          String base64Encodes(List<int> bytes) => base64.encode(bytes);
          String base64Encode = base64Encodes(bytes); //base64.encode(bytes);
          file64 = base64Encode;
          fileExt = file.extension;
          // print(bytes);
          // print(base64Encode);
          // print(file.size);
          // print(file.extension);
          // print(file.path);
          setState(() {
            var title = file.name.split(".");
            docTitle.text = title[0];
          });
        } else {
          // User canceled the picker
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
        child: Text(
          "Upload",
          style:
              Drawables.adddoccontentstyle(Colors.white, 14.0, FontWeight.w400),
        ),
      ),
    );
  }

  void submit() 
  {
    if (docTitle.text.trim() == "" ||
        docTitle.text == "null") 
        {
      AppUtils.showToastError("Please select Document");
    } else {
      AppUtils.showprogress();
      final api = Provider.of<ApiService>(context, listen: false);
      String extension;
      if (fileExt == 'png' ||
          fileExt == 'jpg' ||
          fileExt == 'jpeg' ||
          fileExt == 'jepg' ||
          fileExt == 'PNG' ||
          fileExt == 'JPG') {
        extension = "data:image/jpeg;base64,";
      } else {
        extension = "data:application/" + fileExt! + ";base64,";
      }

      AddDocReq addDocreq = AddDocReq();
      addDocreq.categoryId = Strings.category == true
          ? Strings.selectedCategory[0].categoryId
          : null;
      addDocreq.description = docDesc.text;
      addDocreq.fileName = docTitle.text;
      addDocreq.projectId = Strings.selectedProject[0].projectId;
      addDocreq.userId = Strings.userID;
      String base64Data = extension + file64;
      List<String> _data = <String>[];
      _data.add(base64Data);
      //addDocreq.file = _data;
      addDocreq.file = base64Data;

      var data = jsonEncode(addDocreq);
      debugPrint(data);
      api.addDoc(addDocreq).then((response) 
      {
        AppUtils.dismissprogress();
        if (response.status!) {
          
          Navigator.popAndPushNamed(context, '/viewdoclist');
          Strings.docID = response.data?[0].documentId;
          print("Doc id--> ${Strings.docID}");

          UpdateRights();

          setState(() {});
        } else {
          AppUtils.showToastError(response.message!);
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        print(onError.toString());
      });
    }
  }
  }

