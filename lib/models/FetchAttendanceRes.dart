class FetchAttendanceRes {
  bool status;
  String message;
  List<AttendanceData> data;

  FetchAttendanceRes({this.status, this.message, this.data});

  FetchAttendanceRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<AttendanceData>();
      json['data'].forEach((v) {
        data.add(new AttendanceData.fromJson(v));
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

class AttendanceData {
  int id;
  int userId;
  String checkType;
  String checkTime;
  String locationName;
  String latLng;
  String createdAt;
  String updatedAt;

  AttendanceData(
      {this.id,
      this.userId,
      this.checkType,
      this.checkTime,
      this.locationName,
      this.latLng,
      this.createdAt,
      this.updatedAt});

  AttendanceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    checkType = json['checkType'];
    checkTime = json['checkTime'];
    locationName = json['location_name'];
    latLng = json['latLng'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['checkType'] = this.checkType;
    data['checkTime'] = this.checkTime;
    data['location_name'] = this.locationName;
    data['latLng'] = this.latLng;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
