

import 'package:hive/hive.dart';
part 'person.g.dart';  // 这行必须在文件开头

@HiveType(typeId: 0)
class Person extends HiveObject {
  @HiveField(0)
  String user_name;

  @HiveField(1)
  String selfInfo;

  @HiveField(2)
  String gender;

  @HiveField(3)
  String avatar;

  @HiveField(4)
  String user_id;

  @HiveField(5)
  String email;

  @HiveField(6)
  String password;

  @HiveField(7)
  int likes_num;

  @HiveField(8)
  String birthday;

  @HiveField(9)
  int collects_num;

  @HiveField(10)
  int followers_num;

  Person({
    required this.user_name,
    required this.selfInfo,
    required this.gender,
    required this.avatar,
    required this.user_id,
    required this.password,
    required this.email,
    required this.likes_num,
    required this.birthday,
    required this.collects_num,
    required this.followers_num,
  });

  void setUserName(String name) {
    this.user_name = name;
  }

  void setSelfIntro(String selfIntro) {
    this.selfInfo = selfIntro;
  }

  void setGender(String gender) {
    this.gender = gender;
  }

  void setAvatar(String avatar) {
    this.avatar = avatar;
  }

  void setPassword(String password) {
    this.password = password;
  }

  void setBirthday(String birthday) {
    this.birthday = birthday;
  }
}
