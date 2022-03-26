class FectchProjectDocRes {
  bool? status;
  String? message;
  List<ProjectDocData>? data;

  FectchProjectDocRes({this.status, this.message, this.data});

  FectchProjectDocRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ProjectDocData>[];
      json['data'].forEach((v) {
        data?.add(new ProjectDocData.fromJson(v));
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

class ProjectDocData {
  int? documentId;
  String? fileName;
  String? file;
  int? userId;
  String? name;
  String? createdAt;
  String? description;
  int? commentsCount;

  ProjectDocData(
      {this.documentId,
      this.fileName,
      this.file,
      this.userId,
      this.name,
      this.createdAt,
      this.description,
      this.commentsCount});

  ProjectDocData.fromJson(Map<String, dynamic> json) {
    documentId = json['document_id'];
    fileName = json['file_name'];
    file = json['file'];
    userId = json['user_id'];
    name = json['name'];
    createdAt = json['created_at'];
    description = json['description'];
    commentsCount = json['commentsCount'];
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
