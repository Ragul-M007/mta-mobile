class TeamUsersRes {
  bool? status;
  String? message;
  List<UsersData>? data;

  TeamUsersRes({this.status, this.message, this.data});

  TeamUsersRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <UsersData>[];
      json['data'].forEach((v) {
        data!.add(new UsersData.fromJson(v));
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

class UsersData {
  int? id;
  int? userId;
  int? teamId;
  String? name;
  String? email;
  String? mobileNo;
  String? userImg;

  UsersData(
      {this.id,
      this.userId,
      this.teamId,
      this.name,
      this.email,
      this.mobileNo,
      this.userImg});

  UsersData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    teamId = json['team_id'];
    name = json['name'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    userImg = json['user_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['team_id'] = this.teamId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile_no'] = this.mobileNo;
    data['user_img'] = this.userImg;
    return data;
  }
}
