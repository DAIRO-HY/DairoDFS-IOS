/*工具自动生成代码,请勿手动修改*/
struct SyncServerModel : Codable {

  	/** 编号 **/
  var no: Int

  	/** 主机端同步连接 **/
  var url: String

  	/** 同步状态 0：待机中   1：同步中  2：同步错误 **/
  var state: Int

  	/** 同步消息 **/
  var msg: String

  	/** 同步进度 **/
  var progress: String

  	/** 总数 **/
  var count: Int

  	/** 最后一次同步完成时间 **/
  var lastTime: String

  	/** 最后一次心跳时间 **/
  var lastHeartTime: String

}
