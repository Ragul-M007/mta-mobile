class BackLinkRes {
  bool? status;
  String? message;
  List<Data>? data;

  BackLinkRes({this.status, this.message, this.data});

  BackLinkRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? backlinkId;
  String? twitterLink;
  String? instagramLink;
  String? linkedin;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.backlinkId,
      this.twitterLink,
      this.instagramLink,
      this.linkedin,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    backlinkId = json['backlink_id'];
    twitterLink = json['twitter_link'];
    instagramLink = json['instagram_link'];
    linkedin = json['linkedin'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['backlink_id'] = this.backlinkId;
    data['twitter_link'] = this.twitterLink;
    data['instagram_link'] = this.instagramLink;
    data['linkedin'] = this.linkedin;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
