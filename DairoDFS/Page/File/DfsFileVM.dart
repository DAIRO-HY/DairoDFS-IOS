
import '../../../api/model/FileModel.dart';

///文件信息试图模型
class DfsFileVM {
  /// 文件id
  late final int id;

  /// 名称
  late final String name;

  /// 大小
  late final int size;

  /// 是否文件
  late final bool fileFlag;

  /// 创建日期
  late final String date;

  /// 文件路径
  late final String path;

  /// 文件缩略图
  late final String thumb;

  /// 是否选中
  var isSelected = false;

  DfsFileVM(String parent, FileModel fileModel) {
    this.id = fileModel.id;
    this.name = fileModel.name;
    this.size = fileModel.size;
    this.fileFlag = fileModel.fileFlag;
    this.date = fileModel.date;
    this.path = "$parent/${fileModel.name}";
    this.thumb = fileModel.thumb;
  }

  ///得到文件预览url
  String get preview => "/app/files/preview/${this.id}/${this.name}";
}
