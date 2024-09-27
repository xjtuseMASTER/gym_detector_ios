//用户信息类
class Person {

String name; //用户名
String sign_name;//个性签名
String sex;//性别
String profile_photo;//头像
String ID; //uuid
String email ;// 邮箱
String code ; //密码
String likes;//累计获点赞数

Person({
  required this.name,
  required this.sign_name,
  required this.sex,
  required this.profile_photo,
  required this.ID,
  required this.code,
  required this.email,
  required this.likes
  
});


 //  预留的后端接口
 // 将JSON数据转换为Restaurant实例
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      sign_name: json['sign_name'],
      sex: json['sex'],
      ID: json['ID'],
      code: json['code'],
      email: json['email'],
      profile_photo: json['profile_photo'],
      likes: json['likses']
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
      profile_photo: "assets/user_images/user-1.png",
      likes: "1w"
    );
  }




}