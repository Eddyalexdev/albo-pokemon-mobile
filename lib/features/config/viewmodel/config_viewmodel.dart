import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';

/// ViewModel for ConfigScreen - manages server URL configuration.
class ConfigViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;

  String _serverUrl = '';
  bool _isLoading = false;
  bool _isBackendReachable = false;
  String? _error;

  ConfigViewModel({required SharedPreferences prefs}) : _prefs = prefs;

  String get serverUrl => _serverUrl;
  bool get isLoading => _isLoading;
  bool get isBackendReachable => _isBackendReachable;
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

  /// Update the backend reachability state.
  void updateReachability(bool isReachable) {
    _isBackendReachable = isReachable;
    notifyListeners();
  }

  /// Performs a health check against the server.
  /// Returns true if the server responds with 2xx on /health or / endpoint.
  /// Returns false on any error, timeout, or non-2xx response.
  Future<bool> healthCheck() async {
    if (_serverUrl.isEmpty) {
      return false;
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    try {
      // Try /health endpoint first
      final healthResponse = await dio.get<void>('$_serverUrl/health');

      if (healthResponse.statusCode != null &&
          healthResponse.statusCode! >= 200 &&
          healthResponse.statusCode! < 300) {
        updateReachability(true);
        return true;
      }

      // Fallback to root endpoint on non-2xx from /health
      final rootResponse = await dio.get<void>(_serverUrl);

      if (rootResponse.statusCode != null &&
          rootResponse.statusCode! >= 200 &&
          rootResponse.statusCode! < 300) {
        updateReachability(true);
        return true;
      }

      updateReachability(false);
      return false;
    } on DioException {
      // 404 from /health - try root endpoint as fallback
      try {
        final rootResponse = await dio.get<void>(_serverUrl);

        if (rootResponse.statusCode != null &&
            rootResponse.statusCode! >= 200 &&
            rootResponse.statusCode! < 300) {
          updateReachability(true);
          return true;
        }
      } catch (_) {
        // Fallback also failed
      }

      updateReachability(false);
      return false;
    } catch (_) {
      updateReachability(false);
      return false;
    }
  }
}
