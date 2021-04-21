class SetPinReq {
  String loginpin;

  SetPinReq({this.loginpin});

  SetPinReq.fromJson(Map<String, dynamic> json) {
    loginpin = json['loginpin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['loginpin'] = this.loginpin;
    return data;
  }
}
