class NotificationRes {
  bool? status;
  String? message;
  List<NotificationData>? data;

  NotificationRes({this.status, this.message, this.data});

  NotificationRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) 
      {
        data!.add(new NotificationData.fromJson(v));
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

class NotificationData {
  int? notiId;
  String? title;
  String? description;
  DocDetail? docDetail;
  String? imgUrl;
  String? createdAt;
  int? readStatus;

  NotificationData(
      {this.notiId,
      this.title,
      this.description,
      this.docDetail,
      this.imgUrl,
      this.createdAt,
      this.readStatus});

  NotificationData.fromJson(Map<String, dynamic> json) {
    notiId = json['noti_id'];
    title = json['title'];
    description = json['description'];
    docDetail = json['doc_detail'] != null
        ? new DocDetail.fromJson(json['doc_detail'])
        : null;
    imgUrl = json['img_url'];
    createdAt = json['created_at'];
    readStatus = json['read_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['noti_id'] = this.notiId;
    data['title'] = this.title;
    data['description'] = this.description;
    if (this.docDetail != null) {
      data['doc_detail'] = this.docDetail!.toJson();
    }
    data['img_url'] = this.imgUrl;
    data['created_at'] = this.createdAt;
    data['read_status'] = this.readStatus;
    return data;
  }
}

class DocDetail {
  String? file;
  int? categoryId;
  String? updatedAt;
  int? projectId;
  int? userId;
  String? fileName;
  String? createdAt;
  String? description;
  int? documentId;
  String? commentId;

  DocDetail(
      {this.file,
      this.categoryId,
      this.updatedAt,
      this.projectId,
      this.userId,
      this.fileName,
      this.commentId,
      this.createdAt,
      this.description,
      this.documentId});

  DocDetail.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    categoryId = json['category_id'];
    updatedAt = json['updated_at'];
    projectId = json['project_id'];
    userId = json['user_id'];
    fileName = json['file_name'];
    commentId = json['parent_comment_id'].toString();
    createdAt = json['created_at'];
    description = json['description'];
    documentId = json['document_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file'] = this.file;
    data['category_id'] = this.categoryId;
    data['updated_at'] = this.updatedAt;
    data['project_id'] = this.projectId;
    data['user_id'] = this.userId;
    data['file_name'] = this.fileName;
    data['parent_comment_id'] = this.commentId;
    data['created_at'] = this.createdAt;
    data['description'] = this.description;
    data['document_id'] = this.documentId;
    return data;
  }
}
