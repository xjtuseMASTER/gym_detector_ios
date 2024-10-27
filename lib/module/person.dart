

// 用户对象
class Person {
  String user_name; // 用户名
  String selfInfo; // 个性签名
  String gender; // 性别
  String avatar; // 头像
  String user_id; // uuid
  String email; // 邮箱
  String password; // 密码
  int likes_num; // 累计获点赞数
  String birthday; // 出生年月
  int collects_num; // 关注数
  int followers_num; // 粉丝数

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
