class DashboardRes {
  bool? status;
  String? message;
  Data? token;
  List<Data>? data;

  DashboardRes({this.status, this.message, this.data});

  DashboardRes.fromJson(Map<String, dynamic> json) 
  {
    status = json['status'];
    message = json['message'];
    token = json['token'] != null ? new Data.fromJson(json['token']) : null;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data?.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.token != null) {
      data['token'] = this.token!.toJson();
    }
    if (this.data != null) 
    {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class Token {
//   int? projectId;
//   String? projectName;

//   Token({this.projectId, this.projectName});

//   Token.fromJson(Map<String, dynamic> json) {
//     projectId = json['project_id'];
//     projectName = json['project_name'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['project_id'] = this.projectId;
//     data['project_name'] = this.projectName;
//     return data;
//   }
// }

class Data 
{
  int? projectId;
  int? categoryId;
  String? projectName;
  String? categoryName;
  String? projectImg;
  String? city;
  String? state;
  String? address;
  String? status;
  String? startDate;
  String? endDate;
  String? description;
  String? latitude;
  String? longitude;
  String? unReadedUserId;

  List<Documents>? documents;

  Data(
      {this.projectId,
      this.categoryId,
      this.projectName,
      this.categoryName,
      this.projectImg,
      this.city,
      this.state,
      this.address,
      this.status,
      this.startDate,
      this.endDate,
      this.description,
      this.documents,
      this.latitude,
      this.longitude,
      this.unReadedUserId
      });

  Data.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    projectId = json['project_id'];
    categoryId = json['category_id'];
    projectName = json['project_name'];
    categoryName = json['category_name'];
    projectImg = json['project_img'];
    city = json['city'];
    state = json['state'];
    address = json['address'];
    status = json['status'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    description = json['description'];
    unReadedUserId = json['un_readed_user_id'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents?.add(new Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['project_id'] = this.projectId;
    data['category_id'] = this.categoryId;
    data['project_name'] = this.projectName;
    data['category_name'] = this.categoryName;
    data['project_img'] = this.projectImg;
    data['city'] = this.city;
    data['state'] = this.state;
    data['address'] = this.address;
    data['status'] = this.status;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['description'] = this.description;
    data['un_readed_user_id'] = this.unReadedUserId;
    if (this.documents != null) {
      data['documents'] = this.documents?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DocumentData 
{
  String? notiId;
  String? projectId;
  String? categoryId;
  String? projectName;
  String? categoryName;
  String? projectImg;
  String? city;
  String? state;
  String? address;
  String? status;
  String? startDate;
  String? endDate;
  String? description;
  List<Documents>? documents;

  DocumentData(
      {
      this.notiId,
      this.projectId,
      this.categoryId,
      this.projectName,
      this.categoryName,
      this.projectImg,
      this.city,
      this.state,
      this.address,
      this.status,
      this.startDate,
      this.endDate,
      this.description,
      this.documents});

  DocumentData.fromJson(Map<String, dynamic> json) 
  {
    notiId = json['notiId'];
    projectId = json['project_id'];
    categoryId = json['category_id'];
    projectName = json['project_name'];
    categoryName = json['category_name'];
    projectImg = json['project_img'];
    city = json['city'];
    state = json['state'];
    address = json['address'];
    status = json['status'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    description = json['description'];
    if (json['documents'] != null) 
    {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents?.add(new Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() 
  {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notiId'] = this.notiId;
    data['project_id'] = this.projectId;
    data['category_id'] = this.categoryId;
    data['project_name'] = this.projectName;
    data['category_name'] = this.categoryName;
    data['project_img'] = this.projectImg;
    data['city'] = this.city;
    data['state'] = this.state;
    data['address'] = this.address;
    data['status'] = this.status;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['description'] = this.description;
    if (this.documents != null) {
      data['documents'] = this.documents?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Documents {
  String? name;
  int? userId;
  String? fileUrl;
  String? userName;
  String? createdAt;
  int? documentId;

  Documents(
      {this.name,
      this.userId,
      this.fileUrl,
      this.userName,
      this.createdAt,
      this.documentId});

  Documents.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    userId = json['user_id'];
    fileUrl = json['file_url'];
    userName = json['user_name'];
    createdAt = json['created_at'];
    documentId = json['document_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['user_id'] = this.userId;
    data['file_url'] = this.fileUrl;
    data['user_name'] = this.userName;
    data['created_at'] = this.createdAt;
    data['document_id'] = this.documentId;
    return data;
  }
}
