enum ApiConst{

  //页面初始化
  static let INDEX_HTML = "/index.html"

  static let APP_ABOUT_HTML = "/app/about.html"

  //高级功能
  static let APP_ADVANCED_HTML = "/app/advanced.html"

  static let APP_ADVANCED_INIT = "/app/advanced/init"

  //页面数据初始化
  static let APP_ADVANCED_EXEC_SQL = "/app/advanced/exec_sql"

  //开始处理线程
  static let APP_ADVANCED_RE_HANDLE = "/app/advanced/re_handle"

  //获取DFS正在使用的文件大小
  static let APP_ADVANCED_USED_SIZE = "/app/advanced/used_size"

  //立即回收未使用的文件
  static let APP_ADVANCED_RECYCLE_NOW = "/app/advanced/recycle_now"

  //备份数据库
  static let APP_ADVANCED_DB_BACKUP = "/app/advanced/db_backup"

  //重置并同步本机数据
  static let APP_ADVANCED_RESET_DATA = "/app/advanced/reset_data"

  //高级功能：文件验证
  //文件验证同步锁
  //当前正在文件验证的writer
  //停止标记
  //标记是否正在运行
  //当前正在验证的文件数量
  //验证失败的文件
  //验证文件完整
  static let APP_ADVANCED_VALIDATE_FILE_MD5 = "/app/advanced/validate_file_md5"

  //文件上传Controller
  //浏览器文件上传
  static let APP_FILE_UPLOAD = "/app/file_upload"

  //ByStream 以流的方式上传文件
  static let APP_FILE_UPLOAD_BY_STREAM_MD5_ = "/app/file_upload/by_stream/{md5}"

  //GetUploadedSize 获取文件已经上传大小
  //md5 文件的MD5
  static let APP_FILE_UPLOAD_GET_UPLOADED_SIZE = "/app/file_upload/get_uploaded_size"

  //stat 通过MD5上传
  //md5 文件md5
  //path 文件路径
  static let APP_FILE_UPLOAD_BY_MD5 = "/app/file_upload/by_md5"

  //检查文件是否已经存在
  //- md5 文件的md5,多个以逗号分隔
  static let APP_FILE_UPLOAD_CHECK_EXISTS_BY_MD5 = "/app/file_upload/check_exists_by_md5"

  //文件列表页面
  static let APP_FILES_HTML = "/app/files.html"

  //获取文件列表
  static let APP_FILES_GET_LIST = "/app/files/get_list"

  //获取相册列表
  static let APP_FILES_GET_ALBUM_LIST = "/app/files/get_album_list"

  //GetAlbumListV2 -获取相册列表(版本2)
  static let APP_FILES_GET_ALBUM_LIST_V2 = "/app/files/get_album_list/v2"

  //获取扩展文件的所有key值
  //id 文件id
  static let APP_FILES_GET_EXTRA_KEYS = "/app/files/get_extra_keys"

  //创建文件夹
  static let APP_FILES_CREATE_FOLDER = "/app/files/create_folder"

  //删除文件
  static let APP_FILES_DELETE = "/app/files/delete"

  //删除文件
  static let APP_FILES_DELETE_BY_IDS = "/app/files/delete_by_ids"

  //重命名
  //sourcePath 源路径
  //name 新名称
  static let APP_FILES_RENAME = "/app/files/rename"

  //文件复制
  //sourcePaths 源路径
  //targetFolder 目标文件夹
  //isOverWrite 是否覆盖目标文件
  static let APP_FILES_COPY = "/app/files/copy"

  //文件移动
  //sourcePaths 源路径
  //targetFolder 目标文件夹
  //isOverWrite 是否覆盖目标文件
  static let APP_FILES_MOVE = "/app/files/move"

  //分享文件
  static let APP_FILES_SHARE = "/app/files/share"

  //文件或文件夹属性
  //请使用GetPropertyV2
  //paths 选择的路径列表
  static let APP_FILES_GET_PROPERTY = "/app/files/get_property"

  //文件或文件夹属性
  //paths 选择的路径列表
  static let APP_FILES_GET_PROPERTY_V2 = "/app/files/get_property/v2"

  //修改文件类型
  //path 文件路径
  //contentType 文件类型
  static let APP_FILES_SET_CONTENT_TYPE = "/app/files/set_content_type"

  static let APP_FILES_DOWNLOAD_HISTORY_ = "/app/files/download_history/"

  //请使用Extra
  //文件预览
  //dfsId dfs文件ID
  //name 文件名
  //extra 要预览的附属文件名
  static let APP_FILES_PREVIEW_DFSID_NAME_ = "/app/files/preview/{dfsId}/{name}"

  //Extra - 获取附属文件
  //dfsId dfs文件ID
  //name 文件名
  //extra 要预览的附属文件名
  static let APP_FILES_EXTRA_DFSID_NAME_ = "/app/files/extra/{dfsId}/{name}"

  //文件下载
  //name 文件名
  //folder 所在文件夹
  static let APP_FILES_DOWNLOAD_ = "/app/files/download/"

  //缩略图下载
  //id 文件ID
  static let APP_FILES_THUMB_ID_ = "/app/files/thumb/{id}"

  //缩略图生成单线程限制
  //ThumbOnline - 缩略图在线生成
  //优先使用maxSize
  //id 文件ID
  //name 文件名
  //width 宽
  //height 高
  //maxSize 最大边
  static let APP_FILES_THUMB_ONLINE_ID_NAME_ = "/app/files/thumb_online/{id}/{name}"

  //获取文件夹结构
  static let APP_FOLDER_SELECTOR_GET_LIST = "/app/folder_selector/get_list"

  //管理员账号初始化
  static let APP_INSTALL_CREATE_ADMIN = "/app/install/create_admin"

  //账号初始化API
  static let APP_INSTALL_CREATE_ADMIN_ADD_ADMIN = "/app/install/create_admin/add_admin"

  static let APP_INSTALL_DISTRIBUTED = "/app/install/distributed"

  static let APP_INSTALL_DISTRIBUTED_SET = "/app/install/distributed/set"

  static let APP_INSTALL_EXIFTOOL = "/app/install/exiftool"

  //资源回收
  static let APP_INSTALL_EXIFTOOL_RECYCLE = "/app/install/exiftool/recycle"

  static let APP_INSTALL_EXIFTOOL_INSTALL = "/app/install/exiftool/install"

  //当前安装进度
  static let APP_INSTALL_EXIFTOOL_PROGRESS = "/app/install/exiftool/progress"

  static let APP_INSTALL_FFMPEG = "/app/install/ffmpeg"

  //资源回收
  static let APP_INSTALL_FFMPEG_RECYCLE = "/app/install/ffmpeg/recycle"

  static let APP_INSTALL_FFMPEG_INSTALL = "/app/install/ffmpeg/install"

  //当前安装进度
  static let APP_INSTALL_FFMPEG_PROGRESS = "/app/install/ffmpeg/progress"

  static let APP_INSTALL_FFPROBE = "/app/install/ffprobe"

  //资源回收
  static let APP_INSTALL_FFPROBE_RECYCLE = "/app/install/ffprobe/recycle"

  static let APP_INSTALL_FFPROBE_INSTALL = "/app/install/ffprobe/install"

  //当前安装进度
  static let APP_INSTALL_FFPROBE_PROGRESS = "/app/install/ffprobe/progress"

  static let APP_INSTALL_LIBRAW = "/app/install/libraw"

  //资源回收
  static let APP_INSTALL_LIBRAW_RECYCLE = "/app/install/libraw/recycle"

  static let APP_INSTALL_LIBRAW_INSTALL = "/app/install/libraw/install"

  //当前安装进度
  static let APP_INSTALL_LIBRAW_PROGRESS = "/app/install/libraw/progress"

  static let APP_INSTALL_MAGICK = "/app/install/magick"

  //资源回收
  static let APP_INSTALL_MAGICK_RECYCLE = "/app/install/magick/recycle"

  static let APP_INSTALL_MAGICK_INSTALL = "/app/install/magick/install"

  //当前安装进度
  static let APP_INSTALL_MAGICK_PROGRESS = "/app/install/magick/progress"

  static let APP_INSTALL_SET_STORAGE = "/app/install/set_storage"

  static let APP_INSTALL_SET_STORAGE_SET = "/app/install/set_storage/set"

  //登录页面
  static let APP_LOGIN = "/app/login"

  static let APP_LOGIN_DO_LOGIN = "/app/login/do_login"

  static let APP_LOGIN_LOGOUT = "/app/login/logout"

  //系统设置
  //页面初始化
  static let APP_MINE_HTML = "/app/mine.html"

  //页面初始化
  static let APP_MINE_INIT = "/app/mine/init"

  static let APP_MINE_MAKE_API_TOKEN = "/app/mine/make_api_token"

  static let APP_MINE_MAKE_URL_PATH = "/app/mine/make_url_path"

  static let APP_MINE_MAKE_ENCRYPTION = "/app/mine/make_encryption"

  //密码修改
  static let APP_MODIFY_PWD_HTML = "/app/modify_pwd.html"

  //修改密码
  static let APP_MODIFY_PWD_MODIFY = "/app/modify_pwd/modify"

  static let APP_MY_SHARE_HTML = "/app/my_share.html"

  //获取所有的分享
  static let APP_MY_SHARE_GET_LIST = "/app/my_share/get_list"

  //获取分享详细
  //id 分享id
  static let APP_MY_SHARE_GET_DETAIL = "/app/my_share/get_detail"

  //取消所选分享
  //ids 分享id列表
  static let APP_MY_SHARE_DELETE = "/app/my_share/delete"

  //系统配置
  //页面初始化
  static let APP_PROFILE_HTML = "/app/profile.html"

  //页面数据初始化
  static let APP_PROFILE_INIT = "/app/profile/init"

  //页面初始化
  static let APP_PROFILE_UPDATE = "/app/profile/update"

  //切换token
  static let APP_PROFILE_MAKE_TOKEN = "/app/profile/make_token"

  //数据同步状态
  static let APP_SYNC_HTML = "/app/sync.html"

  //页面数据初始化
  static let APP_SYNC_INFO_LIST = "/app/sync/info_list"

  //日志同步
  static let APP_SYNC_BY_LOG = "/app/sync/by_log"

  //全量同步
  static let APP_SYNC_BY_TABLE = "/app/sync/by_table"

  //当前同步状态
  static let APP_SYNC_INFO = "/app/sync/info"

  static let APP_TRASH_HTML = "/app/trash.html"

  //获取回收站文件列表
  static let APP_TRASH_GET_LIST = "/app/trash/get_list"

  //彻底删除文件
  //ids 选中的文件ID列表
  static let APP_TRASH_LOGIC_DELETE = "/app/trash/logic_delete"

  //从垃圾箱还原文件
  //ids 选中的文件ID列表
  static let APP_TRASH_TRASH_RECOVER = "/app/trash/trash_recover"

  //立即回收储存空间
  static let APP_TRASH_RECYCLE_STORAGE = "/app/trash/recycle_storage"

  //用户编辑
  static let APP_USER_EDIT_HTML = "/app/user_edit.html"

  static let APP_USER_EDIT_INIT = "/app/user_edit/init"

  static let APP_USER_EDIT_EDIT = "/app/user_edit/edit"

  //用户列表
  static let APP_USER_LIST_HTML = "/app/user_list.html"

  static let APP_USER_LIST_INIT = "/app/user_list/init"

  //提取分享的文件
  //页面初始化
  static let SHARE_EID_INIT = "/share/{eid}/init"

  //输入密码
  static let SHARE_EID_PWD = "/share/{eid}/pwd"

  //验证密码
  //id 分享ID
  static let SHARE_EID_VALID_PWD = "/share/{eid}/valid_pwd"

  static let SHARE_EID_SAVE_TO = "/share/{eid}/save_to"

  //GetList 重置密码
  //id 分享ID
  //folder 分享的文件夹路径
  static let SHARE_EID_GET_LIST = "/share/{eid}/get_list"

  //Download 文件下载
  //request 客户端请求
  //response 往客户端返回内容
  //id 分享ID
  //name 文件名
  //folder 所在文件夹
  static let SHARE_EID_DOWNLOAD_NAME_ = "/share/{eid}/download/{name}"

  //缩略图
  //request 客户端请求
  //response 往客户端返回内容
  //id 文件ID
  static let SHARE_EID_THUMB = "/share/{eid}/thumb"
}