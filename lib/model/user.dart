class User {
  String id;
  String phone;

  User({this.id, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['phone'] = this.phone;
    return data;
  }
}
