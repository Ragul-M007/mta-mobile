class MetionUserModel {
  String? id;
  String? display;
  String? fullName;
  String? photo;

  MetionUserModel({this.id, this.display, this.fullName, this.photo});

  MetionUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    display = json['display'];
    fullName = json['full_name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['display'] = this.display;
    data['full_name'] = this.fullName;
    data['photo'] = this.photo;
    return data;
  }
}
