class SetPinReq {
  String? loginpin;
  String? emailId;

  SetPinReq({this.loginpin,
  this.emailId});

  SetPinReq.fromJson(Map<String, dynamic> json) {
    loginpin = json['loginpin'];
    emailId = json['email_id'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['loginpin'] = this.loginpin;
    data['email_id'] = this.emailId;
    return data;
  }
}
