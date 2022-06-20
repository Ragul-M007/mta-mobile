class FectchProjectDocRes {
  bool? status;
  String? message;
  List<ProjectDocData>? data;

  FectchProjectDocRes({this.status, this.message, this.data});

  FectchProjectDocRes.fromJson(Map<String, dynamic> json) 
  {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null)
    {
      data = <ProjectDocData>[];
      json['data'].forEach((v) 
      {
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
  String? notiId;
  String? projectId;
  String? documentId;
  String? fileName;
  String? file;
  String? userId;
  String? name;
  String? createdAt;
  String? description;
  String? commentsCount;
  String? commentId;

  ProjectDocData(
    
      {
        this.notiId,
        this.commentId,
      this.projectId,
      this.documentId,
      this.fileName,
      this.file,
      this.userId,
      this.name,
      this.createdAt,
      this.description,
      this.commentsCount});

  ProjectDocData.fromJson(Map<String, dynamic> json) 
  {
    commentId = json["parent_comment_id"];
    documentId = json['document_id'].toString();
    projectId = json['project_id'].toString();
    fileName = json['file_name'];
    notiId = json['noti_id'];
    file = json['file'];
    userId = json['user_id'].toString();
    name = json['name'];
    createdAt = json['created_at'];
    description = json['description'];
    commentsCount = json['commentsCount'].toString();
  }

  Map<String, dynamic> toJson() 
  {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['document_id'] = this.documentId;
        data['project_id'] = this.projectId;
    data['file_name'] = this.fileName;
    data['parent_comment_id'] = this.commentId;
    data['noti_id'] = this.notiId;
    data['file'] = this.file;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['description'] = this.description;
    data['commentsCount'] = this.commentsCount;
    return data;
  }
}
