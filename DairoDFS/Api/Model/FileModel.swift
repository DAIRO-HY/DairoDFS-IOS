struct FileModel : Codable {

  	/** 文件id **/
  var id: Int64

  	/** 名称 **/
  var name: String

  	/** 大小 **/
  var size: Int64

  	/** 是否文件 **/
  var fileFlag: Bool

  	/** 创建日期(毫秒) **/
  var date: Int64

  	/** 是否有缩略图 **/
  var hasThumb: Bool

  	/** 视频总时长(毫秒),只有相册列表有值 **/
  var duration: Int64? = nil

}
