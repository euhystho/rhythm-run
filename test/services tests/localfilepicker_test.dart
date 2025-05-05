import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/data/services/localfilepicker.dart';
import 'dart:io';

void main() {
  group('Audio File Picker Integration Tests (real device)', () {
    test('pickAudioFile returns a non-null set of strings', () async {
      final result = await pickAudioFile();

      expect(result, isA<Set<String>>());
    });

    test('_getPermisionAndroid returns a boolean', () async {
      if (Platform.isAndroid) {
        final granted = await getPermisionAndroid();
        expect(granted, isA<bool>());
      } else {
        expect(() => getPermisionAndroid(), returnsNormally);
      }
    });

    test('_androidMusicDirectory returns a Directory or null', () async {
      if (Platform.isAndroid) {
        final dir = await androidMusicDirectory();
        expect(dir, anyOf([isNull, isA<Directory>()]));
      }
    });

    test('_getPermisionIOS returns true on iOS', () async {
      if (Platform.isIOS) {
        final granted = await getPermisionIOS();
        expect(granted, true);
      }
    });

    test('_iosMusicDirectory returns null', () async {
      if (Platform.isIOS) {
        final dir = await iosMusicDirectory();
        expect(dir, null);
      }
    });
  });
}
