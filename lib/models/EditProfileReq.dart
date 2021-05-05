class EditProfileReq {
  String name;
  String mobileNo;
  String userImg;
  String city;
  String area;
  String state;

  EditProfileReq(
      {this.name,
      this.mobileNo,
      this.userImg,
      this.city,
      this.area,
      this.state});

  EditProfileReq.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mobileNo = json['mobile_no'];
    userImg = json['user_img'];
    city = json['city'];
    area = json['area'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['mobile_no'] = this.mobileNo;
    data['user_img'] = this.userImg;
    data['city'] = this.city;
    data['area'] = this.area;
    data['state'] = this.state;
    return data;
  }
}
