import 'package:mta/models/Chat/ChatMessageRes.dart';

class ChatMessageWithPageCountRes {
  bool? status;
  String? message;
  List<ChatMessageRes>? data;
  int? nextpage;

  ChatMessageWithPageCountRes(
      {this.status, this.message, this.data, this.nextpage});

  ChatMessageWithPageCountRes.fromJson(Map<String, dynamic> json) 
  {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ChatMessageRes>[];
      json['data'].forEach((v) {
        data!.add(new ChatMessageRes.fromJson(v));
      });
    }
    nextpage = json['nextpage'];
  }

  Map<String, dynamic> toJson() 
  {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['nextpage'] = this.nextpage;
    return data;
  }
}


