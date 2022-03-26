class AddAttendanceReq {
  String? checkType;
  String? checkTime;
  String? latLng;
  String? locationName;

  AddAttendanceReq(
      {this.checkType, this.checkTime, this.latLng, this.locationName});

  AddAttendanceReq.fromJson(Map<String, dynamic> json) {
    checkType = json['checkType'];
    checkTime = json['checkTime'];
    latLng = json['latLng'];
    locationName = json['location_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checkType'] = this.checkType;
    data['checkTime'] = this.checkTime;
    data['latLng'] = this.latLng;
    data['location_name'] = this.locationName;
    return data;
  }
}
