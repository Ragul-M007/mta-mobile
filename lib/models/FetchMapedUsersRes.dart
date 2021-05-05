class FetchMapedUsersRes {
  bool status;
  String message;
  List<FetchMapedUsersData> data;

  FetchMapedUsersRes({this.status, this.message, this.data});

  FetchMapedUsersRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<FetchMapedUsersData>();
      json['data'].forEach((v) {
        data.add(new FetchMapedUsersData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FetchMapedUsersData {
  int userId;
  int roleId;
  String name;
  String email;
  String mobileNo;
  String status;
  String userImg;
  String dob;
  String city;
  String area;
  String state;
  String anniverDate;
  String deviceToken;
  String createdAt;
  String updatedAt;

  FetchMapedUsersData(
      {this.userId,
      this.roleId,
      this.name,
      this.email,
      this.mobileNo,
      this.status,
      this.userImg,
      this.dob,
      this.city,
      this.area,
      this.state,
      this.anniverDate,
      this.deviceToken,
      this.createdAt,
      this.updatedAt});

  FetchMapedUsersData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    roleId = json['role_id'];
    name = json['name'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    status = json['status'];
    userImg = json['user_img'];
    dob = json['dob'];
    city = json['city'];
    area = json['area'];
    state = json['state'];
    anniverDate = json['anniver_date'];
    deviceToken = json['device_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['role_id'] = this.roleId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile_no'] = this.mobileNo;
    data['status'] = this.status;
    data['user_img'] = this.userImg;
    data['dob'] = this.dob;
    data['city'] = this.city;
    data['area'] = this.area;
    data['state'] = this.state;
    data['anniver_date'] = this.anniverDate;
    data['device_token'] = this.deviceToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
