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
    isInApp_Reminder: json['isInApp_Reminder']==0?false:true,
    outInApp_Reminder: json['outInApp_Reminder']==0?false:true,
    isLightTheme: json['isLightTheme']==0?false:true,
    isLikesVisible: json['isLikesVisible']==0?false:true,
    isReleaseVisible: json['isReleaseVisible']==0?false:true,
    isCollectsVisible: json['isCollectsVisible']==0?false:true
  );
}
    
    void setisInApp_Reminder(bool isInApp_Reminder){
      this.isInApp_Reminder=isInApp_Reminder;
    
  }
   void setoutInApp_Reminder(bool isInApp_Reminder){
      this.outInApp_Reminder=isInApp_Reminder;
    
  }
   void setisLightTheme(bool isInApp_Reminder){
      this.isLightTheme=isInApp_Reminder;
    
  }
   void setisReleaseVisible(bool isInApp_Reminder){
      this.isReleaseVisible=isInApp_Reminder;
    
  }
  void setisLikesVisible(bool isInApp_Reminder){
      this.isLikesVisible=isInApp_Reminder;
    
  }

}