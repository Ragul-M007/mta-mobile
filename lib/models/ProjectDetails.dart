class ProjectDetailsRes {
  bool? status;
  String? message;
  List<Data>? data;

  ProjectDetailsRes({this.status, this.message, this.data});

  ProjectDetailsRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['Message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['Message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? projectId;
  String? projectName;
  String? description;
  String? state;
  String? city;
  String? address;
  String? status;
  String? projectImg;
  String? startDate;
  String? endDate;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.projectId,
      this.projectName,
      this.description,
      this.state,
      this.city,
      this.address,
      this.status,
      this.projectImg,
      this.startDate,
      this.endDate,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    projectId = json['project_id'];
    projectName = json['project_name'];
    description = json['description'];
    state = json['state'];
    city = json['city'];
    address = json['address'];
    status = json['status'];
    projectImg = json['project_img'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project_id'] = this.projectId;
    data['project_name'] = this.projectName;
    data['description'] = this.description;
    data['state'] = this.state;
    data['city'] = this.city;
    data['address'] = this.address;
    data['status'] = this.status;
    data['project_img'] = this.projectImg;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
