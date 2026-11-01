/// 相册里的一条数据,服务端为了减小数据量,以数组的形式返回:[文件ID, 拍摄时间(秒), 扩展名, 是否有缩略图, 视频时长(毫秒,图片为0)]
struct AlbumItemModel : Codable {

  var id: Int64

  var time: Int64

  var ext: String

  var hasThumb: Bool

  var duration: Int64

  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    self.id = try container.decode(Int64.self)
    self.time = try container.decode(Int64.self)
    self.ext = try container.decode(String.self)
    self.hasThumb = try container.decode(Bool.self)
    self.duration = try container.decode(Int64.self)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(self.id)
    try container.encode(self.time)
    try container.encode(self.ext)
    try container.encode(self.hasThumb)
    try container.encode(self.duration)
  }

  /// 转换成文件信息,相册接口没有返回文件名和大小,文件名用文件ID代替
  var fileModel: FileModel{
    return FileModel(id: self.id, name: "\(self.id).\(self.ext)", size: 0, fileFlag: true, date: self.time * 1000, hasThumb: self.hasThumb, duration: self.duration)
  }
}
