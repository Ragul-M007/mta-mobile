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
      json['data'].forEach((v) {
        data?.add(new NotificationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationData {
  String? title;
  String? description;
  String? imgUrl;
  List<DocDetail>? docDetail;
  String? createdAt;

  NotificationData(
      {this.title,
      this.description,
      this.imgUrl,
      this.docDetail,
      this.createdAt});

  NotificationData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    imgUrl = json['img_url'];
    if (json['doc_detail'] != null) {
      docDetail = <DocDetail>[];
      json['doc_detail'].forEach((v) {
        docDetail?.add(new DocDetail.fromJson(v));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['img_url'] = this.imgUrl;
    if (this.docDetail != null) {
      data['doc_detail'] = this.docDetail?.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    return data;
  }
}

class DocDetail {
  int? documentId;
  String? fileName;
  String? file;
  int? projectId;
  String? projectName;

  DocDetail(
      {this.documentId,
      this.fileName,
      this.file,
      this.projectId,
      this.projectName});

  DocDetail.fromJson(Map<String, dynamic> json) {
    documentId = json['document_id'];
    fileName = json['file_name'];
    file = json['file'];
    projectId = json['project_id'];
    projectName = json['project_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['document_id'] = this.documentId;
    data['file_name'] = this.fileName;
    data['file'] = this.file;
    data['project_id'] = this.projectId;
    data['project_name'] = this.projectName;
    return data;
  }
}
