/*工具自动生成代码,请勿手动修改*/
struct AlbumModel : Codable {

  /** 文件id **/
  var id: Int64

  /** 名称 **/
  var name: String

  /** 大小 **/
  var size: Int64

  /** 是否文件 **/
  var fileFlag: Bool

  /** 创建日期 **/
  var date: Int64

  /** 缩率图 **/
  var thumb: String

  /** 属性 **/
//Property string `json:"property"`
///** 拍摄时间 **/
//CameraDate int64 `json:"cameraDate"`
/** 相机名 **/
  var cameraName: String

  /** 视频时长 **/
  var duration: String

}
