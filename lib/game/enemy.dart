import 'dart:convert';

Enemy userFromJson(String str) => Enemy.fromJson(json.decode(str));

class Enemy {

  Enemy({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.imageUrl
  });

  int id;
  String email;
  String firstName;
  String lastName;
  String imageUrl;

  factory Enemy.fromJson(Map<String, dynamic> json) => Enemy(
    id: json["id"],
    email: json["email"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    imageUrl: json["avatar"]
  );
}