class Place {
  String id;
  String placeName;

  Place({this.id, this.placeName});

  Place.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    placeName = json['placeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['placeName'] = this.placeName;
    return data;
  }
}
