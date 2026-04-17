/// API configuration constants.
abstract final class ApiConstants {
  /// Default server URL hint shown in config screen.
  static const String defaultUrlHint = 'http://192.168.X.X:8080';

  /// SharedPreferences keys.
  static const String keyServerUrl = 'server_url';
  static const String keyNickname = 'nickname';

  /// API endpoints (relative to base URL).
  static const String endpointList = '/list';
  static const String endpointListById = '/list'; // Use with query param ?id=X
}
