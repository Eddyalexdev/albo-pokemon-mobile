import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokemon_stadium/features/config/viewmodel/config_viewmodel.dart';

void main() {
  late ConfigViewModel viewModel;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    viewModel = ConfigViewModel(prefs: prefs);
  });

  group('ConfigViewModel', () {
    group('serverUrl', () {
      test('initial serverUrl is empty', () {
        expect(viewModel.serverUrl, '');
      });

      test('updateUrl updates serverUrl', () {
        viewModel.updateUrl('http://localhost:8080');
        expect(viewModel.serverUrl, 'http://localhost:8080');
      });

      test('updateUrl trims whitespace', () {
        viewModel.updateUrl('  http://localhost:8080  ');
        expect(viewModel.serverUrl, 'http://localhost:8080');
      });

      test('updateUrl clears error', () async {
        await viewModel.saveUrl(); // Sets error
        expect(viewModel.error, isNotNull);

        viewModel.updateUrl('http://localhost:8080');

        expect(viewModel.error, isNull);
      });

      test('updateUrl notifies listeners', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.updateUrl('http://localhost:8080');

        expect(notifyCount, 1);
      });
    });

    group('hasUrl', () {
      test('is false when serverUrl is empty', () {
        expect(viewModel.hasUrl, false);
      });

      test('is true when serverUrl is not empty', () {
        viewModel.updateUrl('http://localhost:8080');
        expect(viewModel.hasUrl, true);
      });
    });

    group('savedUrl', () {
      test('returns null when no URL saved', () async {
        SharedPreferences.setMockInitialValues({});
        final freshPrefs = await SharedPreferences.getInstance();
        final freshViewModel = ConfigViewModel(prefs: freshPrefs);

        expect(freshViewModel.savedUrl, isNull);
      });

      test('returns saved URL', () async {
        await prefs.setString('server_url', 'http://192.168.1.1:8080');
        final freshViewModel = ConfigViewModel(prefs: prefs);

        expect(freshViewModel.savedUrl, 'http://192.168.1.1:8080');
      });
    });

    group('loadSavedUrl', () {
      test('loads saved URL into current serverUrl', () async {
        await prefs.setString('server_url', 'http://192.168.1.1:8080');
        viewModel.loadSavedUrl();

        expect(viewModel.serverUrl, 'http://192.168.1.1:8080');
      });

      test('notifies listeners', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.loadSavedUrl();

        expect(notifyCount, 1);
      });
    });

    group('saveUrl', () {
      test('returns false when URL is empty', () async {
        final result = await viewModel.saveUrl();

        expect(result, false);
        expect(viewModel.error, 'Please enter a server URL');
      });

      test('returns false for invalid URL format', () async {
        viewModel.updateUrl('not-a-url');
        final result = await viewModel.saveUrl();

        expect(result, false);
        expect(viewModel.error, contains('valid URL'));
      });

      test('returns false for URL without scheme', () async {
        viewModel.updateUrl('localhost:8080');
        final result = await viewModel.saveUrl();

        expect(result, false);
        expect(viewModel.error, contains('valid URL'));
      });

      test('returns true and saves URL when valid', () async {
        viewModel.updateUrl('http://localhost:8080');
        final result = await viewModel.saveUrl();

        expect(result, true);
        expect(await prefs.getString('server_url'), 'http://localhost:8080');
      });

      test('isLoading is false after save', () async {
        viewModel.updateUrl('http://localhost:8080');
        await viewModel.saveUrl();

        expect(viewModel.isLoading, false);
      });
    });

    group('updateReachability', () {
      test('updates isBackendReachable', () {
        expect(viewModel.isBackendReachable, false);

        viewModel.updateReachability(true);

        expect(viewModel.isBackendReachable, true);
      });

      test('notifies listeners', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.updateReachability(true);

        expect(notifyCount, 1);
      });
    });

    group('healthCheck', () {
      test('returns false when URL is empty', () async {
        viewModel.updateUrl('');
        final result = await viewModel.healthCheck();

        expect(result, false);
      });
    });

    group('error state', () {
      test('error starts as null', () {
        expect(viewModel.error, isNull);
      });

      test('error is cleared when updateUrl is called', () {
        viewModel.saveUrl(); // Sets error
        expect(viewModel.error, isNotNull);

        viewModel.updateUrl('http://localhost:8080');

        expect(viewModel.error, isNull);
      });
    });
  });
}
