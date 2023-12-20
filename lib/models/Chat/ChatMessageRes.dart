
class ChatMessageRes {
  int? isDownloaded;
  int? messageId;
  String? message;
  String? files;
  String? fileName;
  int? groupId;
  int? userId;
  String? userName;
  int? parentMessageId;
  String? createdAt;
  String? updatedAt;
  String? parentMessage;
  String? parentMessageUserName;
  int? parentMessageUserId;

  ChatMessageRes(
      {
      this.messageId,
      this.message,
      this.files,
      this.groupId,
      this.userId,
      this.userName,
      this.parentMessageId,
      this.createdAt,
      this.updatedAt,
      this.parentMessage,
      this.parentMessageUserName,
      this.parentMessageUserId,
      this.isDownloaded,
      this.fileName});

  ChatMessageRes.fromJson(Map<String, dynamic> json) {
    fileName = json['file_name'];
    isDownloaded = json['is_downloaded'];
    messageId = json['message_id'];
    message = json['message'];
    files = json['files'];
    groupId = json['group_id'];
    userId = json['user_id'];
    userName = json['user_name'];
    parentMessageId = json['parent_message_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    parentMessage = json['parent_message'];
    parentMessageUserName = json['parent_message_user_name'];
    parentMessageUserId = json['parent_message_user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file_name'] = this.fileName;
    data['is_downloaded'] = this.isDownloaded;
    data['message_id'] = this.messageId;
    data['message'] = this.message;
    data['files'] = this.files;
    data['group_id'] = this.groupId;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['parent_message_id'] = this.parentMessageId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['parent_message'] = this.parentMessage;
    data['parent_message_user_name'] = this.parentMessageUserName;
    data['parent_message_user_id'] = this.parentMessageUserId;
    return data;
  }
}