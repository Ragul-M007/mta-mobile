class FetchAttendanceResnew {
  bool? status;
  String? message;
  List<AttendanceDataNew>? data;

  FetchAttendanceResnew({this.status, this.message, this.data});

  FetchAttendanceResnew.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AttendanceDataNew>[];
      json['data'].forEach((v) {
        data?.add(new AttendanceDataNew.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AttendanceDataNew {
  int? userId;
  String? date;
  String? checkInTime;
  String? checkOutTime;
  String? checkInLocation;
  String? checkOutLocation;
  String? projectName;
  String? projectImg;

  AttendanceDataNew(
      {this.userId,
      this.date,
      this.checkInTime,
      this.checkOutTime,
      this.checkInLocation,
      this.checkOutLocation,
      this.projectImg,
      this.projectName});

  AttendanceDataNew.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    date = json['date'];
    checkInTime = json['check_in_time'];
    checkOutTime = json['check_out_time'];
    checkInLocation = json['check_in_location'];
    checkOutLocation = json['check_out_location'];
    projectImg = json['project_img'];
    projectName = json['project_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['date'] = this.date;
    data['check_in_time'] = this.checkInTime;
    data['check_out_time'] = this.checkOutTime;
    data['check_in_location'] = this.checkInLocation;
    data['check_out_location'] = this.checkOutLocation;
    data['project_name'] = this.projectName;
    data['project_img'] = this.projectImg;
    return data;
  }
}
