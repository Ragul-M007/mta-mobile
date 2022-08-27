class AudioReq {
  String? audio;
  String? comment;
  String? categoryIdList;
  String? categoryList;
  int? documentId;
  int? projectId;
  String? recipientId;
  String? recipient;
  int? userId;
  int? parent_comment_id;


  AudioReq(
      {this.audio,
      this.comment,
      this.categoryIdList,
      this.categoryList,
      this.documentId,
      this.projectId,
      this.recipientId,
      this.recipient,
      this.userId,
      this.parent_comment_id});

  AudioReq.fromJson(Map<String, dynamic> json) {
    audio = json['audio'];
    comment = json['comment'];
    categoryIdList = json['category_id_list'];
    categoryList = json['category_list'];
    documentId = json['document_id'];
    projectId = json['project_id'];
    recipientId = json['recipient_id'];
    recipient = json['recipient'];
    userId = json['user_id'];
    parent_comment_id = json['parent_comment_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['audio'] = this.audio;
    data['comment'] = this.comment;
    data['category_id_list'] = this.categoryIdList;
    data['category_list'] = this.categoryList;
    data['document_id'] = this.documentId;
    data['project_id'] = this.projectId;
    data['recipient_id'] = this.recipient;
    data['recipient'] = this.recipientId;
    data['user_id'] = this.userId;
    data['parent_comment_id'] = this.parent_comment_id;
    return data;
  }
}
