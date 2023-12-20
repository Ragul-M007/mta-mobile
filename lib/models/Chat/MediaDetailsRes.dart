class MediaDetailsRes {
  bool? status;
  String? message;
  List<MediaData>? data;

  MediaDetailsRes({this.status, this.message, this.data});

  MediaDetailsRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MediaData>[];
      json['data'].forEach((v) {
        data!.add(new MediaData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaData {
  int? messageId;
  String? files;
  String? fileType;
  String? filesName;
  String? fileOriginalName;
  String? createdAt;
  String? fileSize;



  MediaData({this.messageId, this.files, this.fileType});

  MediaData.fromJson(Map<String, dynamic> json) {
    filesName = json['file_name'];
    fileOriginalName = json['file_original_name'];
    fileSize = json['file_size'];
    createdAt = json['created_at'];
    messageId = json['message_id'];
    files = json['files'];
    fileType = json['file_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file_name'] = this.filesName;
    data['file_original_name'] = this.fileOriginalName;
    data['file_size'] = this.fileSize;
    data['created_at'] = this.createdAt;
    data['message_id'] = this.messageId;
    data['files'] = this.files;
    data['file_type'] = this.fileType;
    return data;
  }
}
