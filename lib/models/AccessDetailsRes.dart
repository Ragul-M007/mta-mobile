class AccessDetailsRes {
  bool? status;
  String? message;
  Data? data;

  AccessDetailsRes({this.status, this.message, this.data});

  AccessDetailsRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? userId;
  int? groupCreateAccess;

  Data({this.userId, this.groupCreateAccess});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    groupCreateAccess = json['group_create_access'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['group_create_access'] = this.groupCreateAccess;
    return data;
  }
}
