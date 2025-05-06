import 'dart:convert';
import '../util/JsonSerialize.dart';

///登录信息
class AccountInfo extends JsonSerialize {
  /// 服务器名
  String domain;

  /// 用户名
  String name;

  /// 密码
  String pwd;

  /// 是否当前登录的账号
  bool isLogining = false;

  AccountInfo({this.domain = "", this.name = "", this.pwd = "", this.isLogining = false});

  static AccountInfo fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return AccountInfo.fromMap(map);
  }

  static AccountInfo fromMap(Map<String, dynamic> map) {
    return AccountInfo(domain: map["domain"], name: map["name"], pwd: map["pwd"], isLogining: map["isLogining"]);
  }

  static List<AccountInfo> fromJsonList(String json) {
    List<dynamic> list = jsonDecode(json);
    return AccountInfo.fromMapList(list);
  }

  static List<AccountInfo> fromMapList(List<dynamic> list) {
    return list.map((map) => AccountInfo.fromMap(map)).toList();
  }

  @override
  toJson() => {
    "domain": this.domain,
    "name": this.name,
    "pwd": this.pwd,
    "isLogining": this.isLogining,
  };
}