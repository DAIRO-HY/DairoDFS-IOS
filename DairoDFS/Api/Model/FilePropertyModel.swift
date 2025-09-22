/*工具自动生成代码,请勿手动修改*/
struct FilePropertyModel : Codable {

  	/** 名称 **/
  var name: String

  	/** 路径 **/
  var path: String

  	/** 大小 **/
  var size: String

  	/** 文件类型(文件专用) **/
  var contentType: String

  	/** 创建日期 **/
  var date: String

  	/** 是否文件 **/
  var isFile: Bool

  	/** 文件数(文件夹属性专用) **/
  var fileCount: Int

  	/** 文件夹数(文件夹属性专用) **/
  var folderCount: Int

  	/** 历史记录(文件属性专用) **/
  var historyList: [FilePropertyHistoryModel]

  	/** 扩展文件列表 **/
  var extraList: [FilePropertyExtraModel]

}
