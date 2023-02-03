class FetchAttendanceRes {
  FetchAttendanceRes({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<AttendanceData> data;
  
  FetchAttendanceRes.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    data = List.from(json['data']).map((e)=>AttendanceData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class AttendanceData {
  AttendanceData({
    required this.checkType,
    required this.checkTime,
    required this.locationName,
   
    
  });
  late final String checkType;
  late final String checkTime;
  late final String locationName;
  
  
  AttendanceData.fromJson(Map<String, dynamic> json){
    checkType = json['checkType'];
    checkTime = json['checkTime'];
  //  latLng = json['latLng'];
    locationName = json['location_name'];
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
  //  _data['created_at'] = createdAt;
  //  _data['updated_at'] = updatedAt;
  //  _data['id'] = id;
  //  _data['user_id'] = userId;
    return _data;
  }
}