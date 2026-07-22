// The pure resume threshold logic: only offer/persist a position that is far
// enough past the start and not into the closing minutes.

import 'package:flutter_test/flutter_test.dart';

import 'package:halo/features/player/resume_policy.dart';

void main() {
  const policy = ResumePolicy();
  const twoHours = Duration(hours: 2);

  group('ResumePolicy.shouldOffer', () {
    test('rejects positions before the 30s minimum', () {
      expect(policy.shouldOffer(const Duration(seconds: 29), twoHours), isFalse);
    });

    test('accepts exactly the 30s minimum', () {
      expect(policy.shouldOffer(const Duration(seconds: 30), twoHours), isTrue);
    });

    test('accepts a comfortable mid-video position', () {
      expect(policy.shouldOffer(const Duration(minutes: 45), twoHours), isTrue);
    });

    test('accepts exactly the end guard boundary (duration - 2min)', () {
      expect(
        policy.shouldOffer(twoHours - const Duration(minutes: 2), twoHours),
        isTrue,
      );
    });

    test('rejects positions within the last two minutes', () {
      expect(
        policy.shouldOffer(twoHours - const Duration(minutes: 1), twoHours),
        isFalse,
      );
    });

    test('rejects when the duration is not yet known', () {
      expect(
        policy.shouldOffer(const Duration(minutes: 10), Duration.zero),
        isFalse,
      );
    });
  });

  group('ResumePolicy.shouldPersist', () {
    test('mirrors shouldOffer for the same inputs', () {
      for (final position in const [
        Duration(seconds: 10),
        Duration(seconds: 30),
        Duration(minutes: 45),
        Duration(hours: 1, minutes: 59),
      ]) {
        expect(
          policy.shouldPersist(position, twoHours),
          policy.shouldOffer(position, twoHours),
          reason: 'persist and offer must agree at $position',
        );
      }
    });
  });
}
