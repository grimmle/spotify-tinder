import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String? token;
  final String? refreshToken;
  final GeoPoint? location;
  final List<String>? alreadySeen;
  final List<String>? liked;
  final List<String>? matched;
  final String? displayName;
  final String? img;

  const User({
    required this.uid,
    this.token,
    this.refreshToken,
    this.location,
    this.alreadySeen,
    this.liked,
    this.matched,
    this.displayName,
    this.img,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uid: json['uid'] as String,
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String,
        location: json['location'] as GeoPoint,
        displayName: json['displayName'] as String,
        alreadySeen: json['alreadySeen'] as List<String>,
        liked: json['liked'] as List<String>,
        matched: json['matched'] as List<String>,
        img: json['img'] as String);
  }
}
