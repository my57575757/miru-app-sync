import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';

class SyncServerApi {
  static final setting = MiruStorage.settings;
  static final dio = Dio(BaseOptions(
    baseUrl: MiruStorage.getSetting(SettingKey.syncAddress),
  ));
  static Future<List<History>> getHistory(String? type) async {
    var history = {
      "userName":setting.get(SettingKey.syncUser),
      "type": type
    };
    var sonEncode2 = jsonEncode(history);
    log(sonEncode2);
    List<dynamic> resList = (await dio.post(setting.get(SettingKey.syncAddress)+"/miru/getMiruHistory",
        data: sonEncode2,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ))).data;
    log("HistoryRes:"+resList.join(","));
    List<History> list = resList.map((e) => History.fromJson(e)).toList();
    return list;
  }

  static Future<List<Favorite>> getFavorites(String? type,String? url,String? package) async {
    var favorite = {
      "userName":setting.get(SettingKey.syncUser),
      "type": type,
      "package": package,
      "url": url
    };
    var sonEncode2 = jsonEncode(favorite);
    log(sonEncode2);
    List<dynamic> resList = (await dio.post(setting.get(SettingKey.syncAddress)+"/miru/getMiruFavorite",
        data: sonEncode2,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ))).data;
    log("FavoritesRes:"+resList.join(","));
    List<Favorite> list = resList.map((e) => Favorite.fromJson(e)).toList();
    return list;
  }

  static Future<History?> getMiruHistory(String package,String url) async {
    var history = {
      'package':package,
      'url':url,
      "userName":setting.get(SettingKey.syncUser)
    };
    var sonEncode2 = jsonEncode(history);
    log(sonEncode2);
    List<dynamic> resList = (await dio.post(setting.get(SettingKey.syncAddress)+"/miru/getMiruHistory",
        data: sonEncode2,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ))).data;
    log("HistoryRes:"+resList.join(","));
    List<History> list = resList.map((e) => History.fromJson(e)).toList();
    return list!=null && list.length>0?list.first:null;
  }

  static Future<void> deleteHistoryByPackageAndUrlSync(String? package, String? url) async {
    var history = {
      'package':package,
      'url':url,
      "userName":setting.get(SettingKey.syncUser)
    };

    var sonEncode2 = jsonEncode(history);
    log(sonEncode2);
    await dio.post(setting.get(SettingKey.syncAddress)+"/miru/delMiruHistory",
        data: sonEncode2,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ));
  }
  static Future<void> deleteFavoritesSync(String? package, String? url) async {
    var history = {
      'package':package,
      'url':url,
      "userName":setting.get(SettingKey.syncUser)
    };

    var sonEncode2 = jsonEncode(history);
    log(sonEncode2);
    await dio.post(setting.get(SettingKey.syncAddress)+"/miru/delMiruFavorite",
        data: sonEncode2,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ));
  }
  static Future<void> addHistory(History history) async {
    var json = history.toJson();
    json['userName'] = setting.get(SettingKey.syncUser);
    var sonEncode2 = jsonEncode(json);
    log(sonEncode2);
    await dio.post(setting.get(SettingKey.syncAddress)+"/miru/addMiruHistory",
        data: sonEncode2,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ));
  }

  static Future<void> addFavorites(Favorite favorite) async {
    var json = favorite.toJson();
    json['userName'] = setting.get(SettingKey.syncUser);
    var sonEncode2 = jsonEncode(json);
    log(sonEncode2);
    await dio.post(setting.get(SettingKey.syncAddress)+"/miru/addMiruFavorite",
        data: sonEncode2,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ));
  }

  static Future<void> update(List<Object> history,String id) async {
    var sonEncode2 = jsonEncode(history);
    log(sonEncode2);
    await dio.post(setting.get(SettingKey.syncAddress)+"/update",
        data: {
          "uuid":setting.get(SettingKey.syncUser)+id,
          "encrypted":jsonEncode(history)
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ));
  }

}
