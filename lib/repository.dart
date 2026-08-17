import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class DataRepository {
  static const _key = 'squadra_data_v1';
  Future<AppData> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return AppData.seed();
    try {
      return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppData.seed();
    }
  }

  Future<void> save(AppData data) async =>
      (await SharedPreferences.getInstance()).setString(
        _key,
        jsonEncode(data.toJson()),
      );
  String export(AppData data) =>
      const JsonEncoder.withIndent('  ').convert(data.toJson());
  AppData import(String raw) =>
      AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  Future<void> copyBackup(AppData data) =>
      Clipboard.setData(ClipboardData(text: export(data)));
}

