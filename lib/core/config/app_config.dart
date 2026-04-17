import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const _baseUrlKey = 'pokemon_stadium_base_url';
  static const _nicknameKey = 'pokemon_stadium_nickname';

  final SharedPreferences _prefs;
  AppConfig(this._prefs);

  String? get baseUrl => _prefs.getString(_baseUrlKey);
  String? get nickname => _prefs.getString(_nicknameKey);

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_baseUrlKey, url);
  }

  Future<void> setNickname(String nick) async {
    await _prefs.setString(_nicknameKey, nick);
  }

  Future<void> clear() async {
    await _prefs.remove(_baseUrlKey);
    await _prefs.remove(_nicknameKey);
  }
}
