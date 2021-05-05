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
  int userId;
  String date;
  String checkInTime;
  String checkOutTime;
  String checkInLocation;
  String checkOutLocation;

  AttendanceData(
      {this.userId,
      this.date,
      this.checkInTime,
      this.checkOutTime,
      this.checkInLocation,
      this.checkOutLocation});

  AttendanceData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    date = json['date'];
    checkInTime = json['check_in_time'];
    checkOutTime = json['check_out_time'];
    checkInLocation = json['check_in_location'];
    checkOutLocation = json['check_out_location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['date'] = this.date;
    data['check_in_time'] = this.checkInTime;
    data['check_out_time'] = this.checkOutTime;
    data['check_in_location'] = this.checkInLocation;
    data['check_out_location'] = this.checkOutLocation;
    return data;
  }
}
