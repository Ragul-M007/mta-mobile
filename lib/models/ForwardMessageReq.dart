class ForwadMessageReq {
  List<int>? documentId;
  List<int>? receiverGroupId;
  String? senderGroupId;
  String? userId;

  ForwadMessageReq(
      {this.documentId, this.receiverGroupId, this.senderGroupId, this.userId});

  ForwadMessageReq.fromJson(Map<String, dynamic> json) {
    documentId = json['document_id'].cast<int>();
    receiverGroupId = json['receiver_group_id'].cast<int>();
    senderGroupId = json['sender_group_id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['document_id'] = this.documentId;
    data['receiver_group_id'] = this.receiverGroupId;
    data['sender_group_id'] = this.senderGroupId;
    data['user_id'] = this.userId;
    return data;
  }
}
