import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';

/// ViewModel for ConfigScreen - manages server URL configuration.
class ConfigViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;

  String _serverUrl = '';
  bool _isLoading = false;
  String? _error;

  ConfigViewModel({required SharedPreferences prefs}) : _prefs = prefs;

  String get serverUrl => _serverUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUrl => _serverUrl.isNotEmpty;

  /// Check if URL was previously saved and return it.
  String? get savedUrl => _prefs.getString(ApiConstants.keyServerUrl);

  /// Load saved URL if exists.
  void loadSavedUrl() {
    _serverUrl = savedUrl ?? '';
    notifyListeners();
  }

  /// Update the server URL text field.
  void updateUrl(String url) {
    _serverUrl = url.trim();
    _error = null;
    notifyListeners();
  }

  /// Validate and save the URL to SharedPreferences.
  Future<bool> saveUrl() async {
    if (_serverUrl.isEmpty) {
      _error = 'Please enter a server URL';
      notifyListeners();
      return false;
    }

    // Basic URL validation
    final uri = Uri.tryParse(_serverUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      _error = 'Please enter a valid URL (e.g., http://192.168.1.1:8080)';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _prefs.setString(ApiConstants.keyServerUrl, _serverUrl);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save URL: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
