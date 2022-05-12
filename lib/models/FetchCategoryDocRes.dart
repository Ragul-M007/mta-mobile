class FetchCategoryDocRes {
  bool? status;
  String? message;
  List<FetchCategoryDoc>? data;

  FetchCategoryDocRes({this.status, this.message, this.data});

  FetchCategoryDocRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <FetchCategoryDoc>[];
      json['data'].forEach((v) {
        data?.add(new FetchCategoryDoc.fromJson(v));
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

class FetchCategoryDoc {
  String? documentId;
  String? fileName;
  String? file;
  String? userId;
  String? name;
  String? createdAt;
  String? description;
  String? commentsCount;

  FetchCategoryDoc(
      {this.documentId,
      this.fileName,
      this.file,
      this.userId,
      this.name,
      this.createdAt,
      this.description,
      this.commentsCount});

  FetchCategoryDoc.fromJson(Map<String, dynamic> json) {
    documentId = json['document_id'].toString();
    fileName = json['file_name'];
    file = json['file'];
    userId = json['user_id'].toString();
    name = json['name'];
    createdAt = json['created_at'];
    description = json['description'];
    commentsCount = json['commentsCount'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['document_id'] = this.documentId;
    data['file_name'] = this.fileName;
    data['file'] = this.file;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['description'] = this.description;
    data['commentsCount'] = this.commentsCount;
    return data;
  }
}
