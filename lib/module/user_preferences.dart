//用户偏好设置类

class UserPreferences {

    bool? isInApp_Reminder; //应用内消息是否开启 默认不开启
    bool? outInApp_Reminder; //应用外消息是否开启 默认不开启
    bool? isLightTheme; //是否选择亮主题，默认为是
    bool? isLikesVisible; //喜欢帖子是否可见
    bool? isReleaseVisible; //发布帖子是否可见
    bool? isCollectsVisible; //收藏帖子是否可见

    UserPreferences({
      required this.isInApp_Reminder,
      required this.outInApp_Reminder,
      required this.isLightTheme,
      required this.isReleaseVisible,
      required this.isCollectsVisible,
      required this.isLikesVisible
    });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
  return UserPreferences(
    isInApp_Reminder: json['isInApp_Reminder'],
    outInApp_Reminder: json['outInApp_Reminder'],
    isLightTheme: json['isLightTheme'],
    isLikesVisible: json['isLikesVisible'],
    isReleaseVisible: json['isReleaseVisible'],
    isCollectsVisible: json['isCollectsVisible']
  );
}
    
    

}