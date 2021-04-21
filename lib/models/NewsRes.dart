class NewsRes {
  bool status;
  String message;
  List<NewsResData> data;

  NewsRes({this.status, this.message, this.data});

  NewsRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<NewsResData>();
      json['data'].forEach((v) {
        data.add(new NewsResData.fromJson(v));
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

class NewsResData {
  int id;
  String titleText;
  String description;
  String imgUrl;
  String feedType;
  String createdAt;
  String updatedAt;

  NewsResData(
      {this.id,
      this.titleText,
      this.description,
      this.imgUrl,
      this.feedType,
      this.createdAt,
      this.updatedAt});

  NewsResData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleText = json['title_text'];
    description = json['description'];
    imgUrl = json['img_url'];
    feedType = json['feed_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title_text'] = this.titleText;
    data['description'] = this.description;
    data['img_url'] = this.imgUrl;
    data['feed_type'] = this.feedType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
