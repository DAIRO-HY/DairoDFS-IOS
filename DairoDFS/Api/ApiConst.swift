/// Api地址
enum ApiConst {

  static let COMMON_GLOBAL = "/api/common/global"

  static let LOGIN_DO_LOGIN = "/api/login/do_login"
  static let LOGIN_LOGOUT = "/api/login/logout"

  static let MINE_INFO = "/api/mine/info"
  static let MODIFY_PWD = "/api/modify_pwd"

  static let FILES_LIST = "/api/files/list"
  static let FILES_ALBUM = "/api/files/album"
  static let FILES_CREATE_FOLDER = "/api/files/create_folder"
  static let FILES_DELETE = "/api/files/delete"
  static let FILES_RENAME = "/api/files/rename"
  static let FILES_COPY = "/api/files/copy"
  static let FILES_MOVE = "/api/files/move"
  static let FILES_PROPERTY = "/api/files/property"

  static let TRASH_LIST = "/api/trash/list"
  static let TRASH_DELETE = "/api/trash/delete"
  static let TRASH_RECOVER = "/api/trash/recover"

  static let FILE_UPLOAD_EXISTS = "/api/file_upload/exists"
}
