class ProfileRes {
  bool? status;
  String? message;
  List<ProfileData>? data;

  ProfileRes({this.status, this.message, this.data});

  ProfileRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ProfileData>[];
      json['data'].forEach((v) {
        data?.add(new ProfileData.fromJson(v));
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

class ProfileData {
  int? userId;
  String? name;
  String? email;
  int? roleId;
  String? mobileNo;
  String? status;
  String? userImg;
  String? dob;
  String? city;
  String? area;
  String? state;
  String? anniverDate;
  String? createdAt;
  String? role;
  String? updatedAt;

  ProfileData(
      {this.userId,
      this.name,
      this.email,
      this.roleId,
      this.mobileNo,
      this.status,
      this.userImg,
      this.dob,
      this.city,
      this.area,
      this.state,
      this.anniverDate,
      this.createdAt,
      this.role,
      this.updatedAt});

  ProfileData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    roleId = json['role_id'];
    mobileNo = json['mobile_no'];
    status = json['status'];
    userImg = json['user_img'];
    dob = json['dob'];
    city = json['city'];
    area = json['area'];
    state = json['state'];
    anniverDate = json['anniver_date'];
    createdAt = json['created_at'];
    role = json['role'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['role_id'] = this.roleId;
    data['mobile_no'] = this.mobileNo;
    data['status'] = this.status;
    data['user_img'] = this.userImg;
    data['dob'] = this.dob;
    data['city'] = this.city;
    data['area'] = this.area;
    data['state'] = this.state;
    data['anniver_date'] = this.anniverDate;
    data['created_at'] = this.createdAt;
    data['role'] = this.role;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
