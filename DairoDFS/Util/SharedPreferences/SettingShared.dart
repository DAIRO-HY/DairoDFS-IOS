
/// 用户设置
struct SettingShared {
/*----------------------------------------------------------------------------------*/

  /// 会员信息
  static const _KEY_USER = "USER";

  /// <summary>
  /// 会员信息
  /// </summary>
  static MineModel? get user => SettingShared._KEY_USER.localObj(MineModel.fromJson);

  static set user(value) {
    SettingShared._KEY_USER.toLocalObj(value);
  }

  /// 后台加载会员信息,不弹出加载等待框
  /// [force] 是否强制刷新数据
  static loadInBackground() {
    // if (!force && SettingShared.user != null){//非强制刷新的情况下,如果已经加载过,就不需要再加载数据
    //     return;
    // }
    MineApi.init().post((user) async {
      SettingShared.user = user;
    });
  }

/*----------------------------------------------------------------------------------*/

  /// 登录Token
  static const _KEY_TOKEN = "TOKEN";
  static String? _token;

  /// <summary>
  /// 登录Token
  /// </summary>
  static String? get token {
    SettingShared._token ??= SyncVariable.sPrefs.getString(SettingShared._KEY_TOKEN);
    return SettingShared._token;
  }

  static set token(value) {
    SettingShared._token = value;
    if (value == null) {
      SyncVariable.sPrefs.remove(SettingShared._KEY_TOKEN);
      return;
    }
    SyncVariable.sPrefs.setString(SettingShared._KEY_TOKEN, value);
  }

/*----------------------------------------------------------------------------------*/

  /// 主题模式
  static const _THEME = "THEME";

  static int get theme {
    return SyncVariable.sPrefs.getInt(SettingShared._THEME) ?? 0;
  }

  static set theme(value) {
    SyncVariable.sPrefs.setInt(SettingShared._THEME, value);
  }

/*----------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------*/

  /// 功能模式
  static const _FUNCTION_MODEL = "FUNCTION_MODEL";

  static int get functionModel {
    return SyncVariable.sPrefs.getInt(SettingShared._FUNCTION_MODEL) ?? FunctionModel.FILE;
  }

  static set functionModel(value) {
    SyncVariable.sPrefs.setInt(SettingShared._FUNCTION_MODEL, value);
  }

  ///获取功能试图
  static Widget get functionView {
    switch (SettingShared.functionModel) {
      case FunctionModel.FILE:
        return HomePage();
      case FunctionModel.ALBUM:
        return AlbumPage();
      default:
        return SizedBox();
    }
  }

/*----------------------------------------------------------------------------------*/

  /// 当前服务器域名
  static const _DOMAIN = "DOMAIN";
  static String? _domain;

  static String get domainNotNull => SettingShared.domain ?? "";

  static String? get domain {
    SettingShared._domain ??= SyncVariable.sPrefs.getString(SettingShared._DOMAIN);
    return SettingShared._domain;
  }

  static set domain(value) {
    SettingShared._domain = value;
    if (value == null) {
      SyncVariable.sPrefs.remove(SettingShared._DOMAIN);
      return;
    }
    SyncVariable.sPrefs.setString(SettingShared._DOMAIN, value);
  }

/*----------------------------------------------------------------------------------*/

  /// 登录过的用户列表
  static List<AccountInfo> get loggedUserList => "loggedUserList".localObj(AccountInfo.fromJsonList) ?? [];

  static set loggedUserList(value) {
    "loggedUserList".toLocalObj(value);
    SettingShared._token = null;
  }

/*----------------------------------------------------------------------------------*/

  /// 同时下载文件数
  static int get downloadSyncCount => SyncVariable.sPrefs.getInt("DOWNLOAD_SYNC_COUNT") ?? 1;

  static set downloadSyncCount(int value) {
    SyncVariable.sPrefs.setInt("DOWNLOAD_SYNC_COUNT", value);
  }

/*----------------------------------------------------------------------------------*/

  /// 同时上传文件数
  static int get uploadSyncCount => SyncVariable.sPrefs.getInt("UPLOAD_SYNC_COUNT") ?? 1;

  static set uploadSyncCount(int value) {
    SyncVariable.sPrefs.setInt("UPLOAD_SYNC_COUNT", value);
  }

/*----------------------------------------------------------------------------------*/

  ///记录当前打开的文件夹
  static const _CURRENT_PATH = "CURRENT_PATH";

  ///获取最后一次打开的文件夹
  static String get lastOpenFolder => SyncVariable.sPrefs.getString(SettingShared._CURRENT_PATH) ?? "";

  static set lastOpenFolder(value) => SyncVariable.sPrefs.setString(SettingShared._CURRENT_PATH, value);

/*----------------------------------------------------------------------------------*/

  /// 排列方式
  static int get sortType => SyncVariable.sPrefs.getInt("SORT_TYPE") ?? FileSortType.NAME;

  static set sortType(int value) {
    SyncVariable.sPrefs.setInt("SORT_TYPE", value);
  }

/*----------------------------------------------------------------------------------*/

  /// 排列升降序
  static int get sortOrderBy => SyncVariable.sPrefs.getInt("SORT_ORDER_BY") ?? FileOrderBy.UP;

  static set sortOrderBy(int value) {
    SyncVariable.sPrefs.setInt("SORT_ORDER_BY", value);
  }

/*----------------------------------------------------------------------------------*/

  /// 文件列表或表格显示类型
  static int get viewType {
    final value = SyncVariable.sPrefs.getInt("VIEW_TYPE");
    if (value != null) {
      return value;
    }
    if (Platform.isIOS || Platform.isAndroid) {
      //移动端默认以列表显示
      return FileViewType.LIST;
    }
    return FileViewType.GRID;
  }

  static set viewType(int value) {
    SyncVariable.sPrefs.setInt("VIEW_TYPE", value);
  }

/*----------------------------------------------------------------------------------*/

  /// 文件下载目录
  static String get downloadPath {
    final downloadPath = SyncVariable.sPrefs.getString("DOWNLOAD_PATH");
    if (downloadPath != null) {
      return downloadPath;
    }
    if (Platform.isIOS) {
      return SyncVariable.documentPath + "/download";
    } else if (Platform.isAndroid) {
      return SyncVariable.downloadPath;
    } else if (Platform.isMacOS) {
      return SyncVariable.supportPath + "/download";
    } else if (Platform.isLinux) {
      return SyncVariable.downloadPath;
    } else if (Platform.isWindows) {
      return SyncVariable.supportPath + "\\download";
    } else
      return "";
  }

  static set downloadPath(String value) {
    SyncVariable.sPrefs.setString("DOWNLOAD_PATH", value);
  }

/*----------------------------------------------------------------------------------*/

  /// 视频播放质量
  static int get videoQuality {
    return SyncVariable.sPrefs.getInt("VIDEO_QUALITY") ?? VideoQualityCode.NORMAL;
  }

  static set videoQuality(int value) {
    SyncVariable.sPrefs.setInt("VIDEO_QUALITY", value);
  }

/*----------------------------------------------------------------------------------*/

  /// 是否登录
  static bool get isLogin => SettingShared.token != null;

  /// 退出登录
  static logout() {
    final logined = SettingShared.loggedUserList;
    logined.forEach((it) => it.isLogining = false);
    SettingShared.loggedUserList = logined;
    SettingShared.token = null;
  }

  /// 登录
  static Future<void> login(
      AccountInfo accountInfo, BuildContext context, VoidCallback success, bool Function(int code, String msg, Object? data) fail) async {
    //先记录登录之前的服务器，如果登录失败，则还原之前的服务器
    var oldDomain = SettingShared.domain;
    SettingShared.domain = accountInfo.domain;
    LoginApi.doLogin(name: accountInfo.name, pwd: accountInfo.pwd, deviceId: await Const.deviceId).fail((code, msg, data) async {
      //登录失败，将服务器还原
      SettingShared.domain = oldDomain;
      return fail(code, msg, data);
    }).post((loginInfo) async {
      //登录成功
      final loggedUserList = SettingShared.loggedUserList;
      for (final it in loggedUserList) {
        it.isLogining = false;
      }
      final currentInfo = loggedUserList.find((it) => it.domain == accountInfo.domain && it.name == accountInfo.name);
      if (currentInfo == null) {
        accountInfo.isLogining = true;
        loggedUserList.add(accountInfo);
      } else {
        //将其标记为登录状态
        currentInfo.isLogining = true;
      }
      SettingShared.loggedUserList = loggedUserList;
      SettingShared.token = loginInfo.token;

      //后台加载用户信息
      SettingShared.loadInBackground();

      //清空缓存的文件列表
      DfsFileShared.clear();

      //通知登录账户更新
      EventUtil.post(EventCode.ACCOUNT_CHANGE);
      success();
    }, context);
  }
}
