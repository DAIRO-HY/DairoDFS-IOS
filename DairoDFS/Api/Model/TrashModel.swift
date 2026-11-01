struct TrashModel : Codable {

  	/** 文件id **/
  var id: Int64

  	/** 名称 **/
  var name: String

  	/** 大小 **/
  var size: Int64

  	/** 是否文件 **/
  var fileFlag: Bool

  	/** 剩余时间文字,例如:29天后删除 **/
  var date: String

  	/** 是否有缩略图 **/
  var hasThumb: Bool

}
