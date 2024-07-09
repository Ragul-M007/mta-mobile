class FetchAttendanceRes {
  bool? status;
  String? message;
  List<AttendanceData>? data;
  String? radius;
  FetchAttendanceRes({
    this.status,
    this.message,
    this.data,
    this.radius,
  });

  FetchAttendanceRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        List.from(json['data']).map((e) => AttendanceData.fromJson(e)).toList();
    radius = json['radius'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data!.map((e) => e.toJson()).toList();
    _data['radius'] = radius;
    return _data;
  }
}

class AttendanceData {
  String? checkType;
  String? checkTime;
  String? locationName;
  String? projectName;
  String? projectImg;
  AttendanceData(
      {this.checkType,
      this.checkTime,
      this.locationName,
      this.projectImg,
      this.projectName});

  AttendanceData.fromJson(Map<String, dynamic> json) {
    checkType = json['checkType'];
    checkTime = json['checkTime'];
    //  latLng = json['latLng'];
    locationName = json['location_name'];

    projectImg = json['project_img'];
    projectName = json['project_name'];
    //  createdAt = json['created_at'];
    //  updatedAt = json['updated_at'];
    //  id = json['id'];
    // userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['checkType'] = checkType;
    _data['checkTime'] = checkTime;
    //  _data['latLng'] = latLng;
    _data['location_name'] = locationName;
    _data['project_name'] = this.projectName;
    _data['project_img'] = this.projectImg;
    //  _data['created_at'] = createdAt;
    //  _data['updated_at'] = updatedAt;
    //  _data['id'] = id;
    //  _data['user_id'] = userId;
    return _data;
  }
}
