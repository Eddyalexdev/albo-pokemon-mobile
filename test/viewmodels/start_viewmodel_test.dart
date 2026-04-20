import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokemon_stadium/features/start/viewmodel/start_viewmodel.dart';

void main() {
  late StartViewModel viewModel;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    viewModel = StartViewModel(prefs: prefs);
  });

  group('StartViewModel', () {
    group('nickname', () {
      test('initial nickname is empty', () {
        expect(viewModel.nickname, '');
      });

      test('updateNickname updates nickname', () {
        viewModel.updateNickname('Ash');
        expect(viewModel.nickname, 'Ash');
      });

      test('updateNickname enforces 12 character limit', () {
        viewModel.updateNickname('ThisIsALongName123');
        // Code doesn't truncate - it rejects input over 12 chars
        expect(viewModel.nickname.length, lessThan(12)); // Stays at previous value
        expect(viewModel.error, 'Nickname must be 12 characters or less');
      });

      test('updateNickname clears error when valid', () {
        viewModel.updateNickname('ThisIsALongName123');
        expect(viewModel.error, isNotNull);

        viewModel.updateNickname('Ash');
        expect(viewModel.error, isNull);
      });
    });

    group('isValid', () {
      test('is false when nickname is empty', () {
        expect(viewModel.isValid, false);
      });

      test('is false when nickname is only whitespace', () {
        viewModel.updateNickname('   ');
        expect(viewModel.isValid, false);
      });

      test('is true when nickname is 1-12 non-whitespace chars', () {
        viewModel.updateNickname('Ash');
        expect(viewModel.isValid, true);
      });

      test('is true when nickname is exactly 12 chars', () {
        viewModel.updateNickname('AshKetchum12');
        expect(viewModel.isValid, true);
      });

      test('is false when nickname exceeds 12 chars', () {
        viewModel.updateNickname('AshKetchum123');
        expect(viewModel.isValid, false);
      });
    });

    group('savedNickname', () {
      test('returns null when no nickname saved', () async {
        SharedPreferences.setMockInitialValues({});
        final freshPrefs = await SharedPreferences.getInstance();
        final freshViewModel = StartViewModel(prefs: freshPrefs);

        expect(freshViewModel.savedNickname, isNull);
      });

      test('returns saved nickname', () async {
        await prefs.setString('nickname', 'Misty');
        final freshViewModel = StartViewModel(prefs: prefs);

        expect(freshViewModel.savedNickname, 'Misty');
      });
    });

    group('loadSavedNickname', () {
      test('loads saved nickname into current nickname', () async {
        await prefs.setString('nickname', 'Brock');
        viewModel.loadSavedNickname();

        expect(viewModel.nickname, 'Brock');
      });

      test('notifies listeners', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.loadSavedNickname();

        expect(notifyCount, 1);
      });
    });

    group('saveNickname', () {
      test('returns false when nickname invalid', () async {
        viewModel.updateNickname('');
        final result = await viewModel.saveNickname();

        expect(result, false);
        expect(viewModel.error, isNotNull);
      });

      test('returns true and saves nickname when valid', () async {
        viewModel.updateNickname('Gary');
        final result = await viewModel.saveNickname();

        expect(result, true);
        expect(await prefs.getString('nickname'), 'Gary');
      });

      test('trims whitespace before saving', () async {
        viewModel.updateNickname('  Oak  ');
        final result = await viewModel.saveNickname();

        expect(result, true);
        expect(await prefs.getString('nickname'), 'Oak');
      });
    });
  });
}
