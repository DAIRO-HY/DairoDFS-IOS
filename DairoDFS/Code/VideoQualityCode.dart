///视频画质值
class VideoQualityCode {
  ///原画
  static const NORMAL = 0;

  ///高清
  static const HIGHT = 1920;

  ///标清
  static const MID = 1280;

  ///流畅
  static const LOW = 640;

  ///code值转显示标题
  static String codeLabel(int? code) {
    switch (code) {
      case HIGHT:
        return "高清";
      case MID:
        return "标清";
      case LOW:
        return "流畅";
      case NORMAL:
        return "原画";
    }
    return "未知";
  }

  ///获取所有的值
  static List<int?> get codes=>[NORMAL,HIGHT,MID,LOW];
}
