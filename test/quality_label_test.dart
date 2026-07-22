// Reading resolution and source out of a release name, for the version picker.

import 'package:flutter_test/flutter_test.dart';

import 'package:halo/features/library/quality_label.dart';

void main() {
  group('qualityLabel', () {
    test('reads resolution and source together', () {
      expect(
        qualityLabel('Dune.2021.1080p.BluRay.x264-GROUP.mkv'),
        '1080p · BluRay',
      );
      expect(
        qualityLabel('Show.S01E01.720p.WEB-DL.mkv'),
        '720p · WEB-DL',
      );
    });

    test('normalises 2160p and UHD to 4K', () {
      expect(qualityLabel('Movie.2160p.mkv'), '4K');
      expect(qualityLabel('Movie.UHD.BluRay.mkv'), '4K · BluRay');
    });

    test('reads either half on its own', () {
      expect(qualityLabel('Movie.1080p.mkv'), '1080p');
      expect(qualityLabel('Movie.WEBRip.mkv'), 'WEBRip');
    });

    test('is null when the name says nothing useful', () {
      // Better to show no label than to invent one.
      expect(qualityLabel('holiday video.mp4'), isNull);
      expect(qualityLabel('Dune.2021.mkv'), isNull);
    });

    test('does not mistake a year or episode code for a resolution', () {
      expect(qualityLabel('1917.2019.mkv'), isNull);
      expect(qualityLabel('Show.S01E480.mkv'), isNull);
    });

    test('handles separators of every common flavour', () {
      expect(qualityLabel('Movie 1080p BluRay.mkv'), '1080p · BluRay');
      expect(qualityLabel('Movie_1080p_BluRay.mkv'), '1080p · BluRay');
      expect(qualityLabel('Movie[1080p][BluRay].mkv'), '1080p · BluRay');
    });
  });

  group('formatFileSize', () {
    test('scales to the unit that reads best', () {
      expect(formatFileSize(8000000000), '7.5 GB');
      expect(formatFileSize(700 * 1024 * 1024), '700 MB');
      expect(formatFileSize(300 * 1024), '300 KB');
    });
  });
}
