import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'user.dart';

class Caregiver extends User {
  final String email;
  String password;

  List<Badge> badges;
  List<ObjectId> friends;

  Caregiver({ObjectId id, this.badges, this.email, this.friends, this.password}) : super(id: id, role: UserRole.caregiver);

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    return Caregiver(
	    id: json['_id'],
      badges: json['badges'] != null ? (json['badges'] as List).map((i) => Badge.fromJson(i)).toList() : [],
      email: json['email'],
      friends: json['friends'] != null ? new List<ObjectId>.from(json['friends']) : [],
      password: json['password'],
    )..fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['email'] = this.email;
    data['password'] = this.password;
    if (this.badges != null) {
      data['badges'] = this.badges.map((v) => v.toJson()).toList();
    }
    if (this.friends != null) {
      data['friends'] = this.friends;
    }
    return data;
  }
}