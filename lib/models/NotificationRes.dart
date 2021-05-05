class NotificationRes {
  bool status;
  String message;
  List<NotificationData> data;

  NotificationRes({this.status, this.message, this.data});

  NotificationRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<NotificationData>();
      json['data'].forEach((v) {
        data.add(new NotificationData.fromJson(v));
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

class NotificationData {
  String title;
  String description;
  String imgUrl;
  String createdAt;

  NotificationData({this.title, this.description, this.imgUrl, this.createdAt});

  NotificationData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    imgUrl = json['img_url'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['img_url'] = this.imgUrl;
    data['created_at'] = this.createdAt;
    return data;
  }
}
