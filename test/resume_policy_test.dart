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

  group('ResumePolicy.actionFor', () {
    // The regression this guards: opening from a saved point reports a
    // position near zero until the seek lands. Discarding on that reading
    // deletes the bookmark the session just resumed from, making resume work
    // exactly once.
    test('keeps a restored point while playback is still catching up', () {
      expect(
        policy.actionFor(Duration.zero, twoHours, restored: true),
        ProgressAction.keep,
      );
      expect(
        policy.actionFor(const Duration(seconds: 3), twoHours, restored: true),
        ProgressAction.keep,
      );
    });

    test('discards a low position when nothing was restored', () {
      expect(
        policy.actionFor(const Duration(seconds: 3), twoHours, restored: false),
        ProgressAction.discard,
      );
    });

    test('saves a real mid-video position either way', () {
      for (final restored in [true, false]) {
        expect(
          policy.actionFor(
            const Duration(minutes: 45),
            twoHours,
            restored: restored,
          ),
          ProgressAction.save,
          reason: 'a genuine position should be written (restored: $restored)',
        );
      }
    });

    test('keeps the stored point until the duration is known', () {
      // Position updates can arrive before duration; nothing can be judged yet.
      expect(
        policy.actionFor(
          const Duration(minutes: 45),
          Duration.zero,
          restored: false,
        ),
        ProgressAction.keep,
      );
    });

    test('a restored session that reaches the credits still stops resuming',
        () {
      // Near the end the position is no longer worth offering, but a restored
      // point is kept rather than discarded; completion is what marks it
      // finished.
      expect(
        policy.actionFor(
          twoHours - const Duration(seconds: 30),
          twoHours,
          restored: true,
        ),
        ProgressAction.keep,
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
