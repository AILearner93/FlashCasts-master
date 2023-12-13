import 'package:cloud_firestore/cloud_firestore.dart';

class UserM {
  UserM(
      {this.imageUrl,
      this.createdAt,
      this.uid,
      this.name,
      this.email,
      this.password});

  UserM.fromJson(dynamic json) {
    imageUrl = json['image_url'];
    createdAt = json['created_at'];
    uid = json['uid'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
  }
  String? imageUrl;
  Timestamp? createdAt;
  String? uid;
  String? name;
  String? email;
  String? password;
  UserM copyWith(
          {String? imageUrl,
          Timestamp? createdAt,
          String? uid,
          String? name,
          String? email,
          String? password}) =>
      UserM(
        imageUrl: imageUrl ?? this.imageUrl,
        createdAt: createdAt ?? this.createdAt,
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['image_url'] = imageUrl;
    map['created_at'] = createdAt;
    map['name'] = name;
    map['email'] = email;
    map['password'] = password;
    return map;
  }
}
