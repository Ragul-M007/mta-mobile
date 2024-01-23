class ChatMessageRes {
  int? messageId;
  String? message;
  String? files;
  String? fileName;
  String? fileOriginalName;
  String? fileSize;
  String? fileType;
  int? groupId;
  int? userId;
  String? userName;
  int? parentMessageId;
  String? parentMessage;
  String? parentFiles;
  String? parentFileName;
  String? parentFileOriginalName;
  String? parentMessageUserName;
  int? parentMessageUserId;
  int? isDownloaded;
  String? messageReadedUsers;
  String? createdAt;
  String? updatedAt;

  ChatMessageRes(
      {this.messageId,
      this.message,
      this.files,
      this.fileName,
      this.fileOriginalName,
      this.fileSize,
      this.fileType,
      this.groupId,
      this.userId,
      this.userName,
      this.parentMessageId,
      this.parentMessage,
      this.parentFiles,
      this.parentFileName,
      this.parentFileOriginalName,
      this.parentMessageUserName,
      this.parentMessageUserId,
      this.isDownloaded,
      this.messageReadedUsers,
      this.createdAt,
      this.updatedAt});

  ChatMessageRes.fromJson(Map<String, dynamic> json) {
    messageId = json['message_id'];
    message = json['message'];
    files = json['files'];
    fileName = json['file_name'];
    fileOriginalName = json['file_original_name'];
    fileSize = json['file_size'];
    fileType = json['file_type'];
    groupId = json['group_id'];
    userId = json['user_id'];
    userName = json['user_name'];
    parentMessageId = json['parent_message_id'];
    parentMessage = json['parent_message'];
    parentFiles = json['parent_files'];
    parentFileName = json['parent_file_name'];
    parentFileOriginalName = json['parent_file_original_name'];
    parentMessageUserName = json['parent_message_user_name'];
    parentMessageUserId = json['parent_message_user_id'];
    isDownloaded = json['is_downloaded'];
    messageReadedUsers = json['message_readed_users'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message_id'] = this.messageId;
    data['message'] = this.message;
    data['files'] = this.files;
    data['file_name'] = this.fileName;
    data['file_original_name'] = this.fileOriginalName;
    data['file_size'] = this.fileSize;
    data['file_type'] = this.fileType;
    data['group_id'] = this.groupId;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['parent_message_id'] = this.parentMessageId;
    data['parent_message'] = this.parentMessage;
    data['parent_files'] = this.parentFiles;
    data['parent_file_name'] = this.parentFileName;
    data['parent_file_original_name'] = this.parentFileOriginalName;
    data['parent_message_user_name'] = this.parentMessageUserName;
    data['parent_message_user_id'] = this.parentMessageUserId;
    data['is_downloaded'] = this.isDownloaded;
    data['message_readed_users'] = this.messageReadedUsers;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
