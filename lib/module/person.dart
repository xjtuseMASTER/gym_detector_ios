//用户对象
class Person {

String name; //用户名
String sign_name;//个性签名
String sex;//性别
String profile_photo;//头像
String ID; //uuid
String email ;// 邮箱
String code ; //密码
int likes;//累计获点赞数
String birthdate;//出生年月
int follow;// 关注数
int fans;//粉丝数

Person({
  required this.name,
  required this.sign_name,
  required this.sex,
  required this.profile_photo,
  required this.ID,
  required this.code,
  required this.email,
  required this.likes,
  required this.birthdate,
  required this.follow,
  required this.fans
});


 //  预留的后端接口
 // 将JSON数据转换为person实例
  factory Person.fromJson(Map<String, dynamic> json) {
  return Person(
    ID: json['id'],
    name: json['name'],
    email: json['email'],
    sign_name: json['sign_name'],
    sex: json['sex'],
    profile_photo: json['profile_photo'],
    code: json['code'],
    likes: json['likes'],
    birthdate: json['birthdate'],
    follow: json['follow'],
    fans: json['fans'],
  );
}


  //测试阶段实例生成的Person对象
  static personGenerator(){
    return Person(
      name: "XE_Man",
      sign_name: "I can do every thing!",
      sex: "Man",
      ID: "1192597201",
      code: "clt123456",
      email: "1192597201@qq.com",
      profile_photo: "assets/user_images/user-1.jpg",
      likes: 10000,
      birthdate: "2003-4-15",
      follow: 300,
      fans: 900
    );
  }




}