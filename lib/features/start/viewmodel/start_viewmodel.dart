import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';

/// ViewModel for StartScreen - manages nickname entry.
class StartViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;

  String _nickname = '';
  String? _error;

  StartViewModel({required SharedPreferences prefs}) : _prefs = prefs;

  String get nickname => _nickname;
  String? get error => _error;
  bool get isValid => _nickname.trim().isNotEmpty && _nickname.length <= 12;

  /// Get saved nickname if any.
  String? get savedNickname => _prefs.getString(ApiConstants.keyNickname);

  /// Load saved nickname.
  void loadSavedNickname() {
    _nickname = savedNickname ?? '';
    notifyListeners();
  }

  /// Update nickname text field.
  void updateNickname(String value) {
    if (value.length <= 12) {
      _nickname = value;
      _error = null;
    } else {
      _error = 'Nickname must be 12 characters or less';
    }
    notifyListeners();
  }

  /// Save nickname and return true if valid.
  Future<bool> saveNickname() async {
    if (!isValid) {
      _error = 'Please enter a nickname (max 12 characters)';
      notifyListeners();
      return false;
    }

    try {
      await _prefs.setString(ApiConstants.keyNickname, _nickname.trim());
      return true;
    } catch (e) {
      _error = 'Failed to save nickname';
      notifyListeners();
      return false;
    }
  }
}
