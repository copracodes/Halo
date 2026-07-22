// The TMDB logo must actually render in TMDB's colours.
//
// The mark styles its paths through a CSS class (`fill:url(#linear-gradient)`)
// rather than a `fill` attribute. If that isn't resolved, the paths fall back
// to SVG's default fill — black — which is invisible on Halo's dark surface and
// looks exactly like "the asset didn't load". Attribution is a licensing
// obligation, so this renders the widget and inspects the pixels rather than
// trusting that it appeared.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halo/core/theme/app_colors.dart';
import 'package:halo/features/metadata/tmdb_attribution.dart';

/// Every distinct colour drawn inside [finder].
///
/// Rasterising is genuinely asynchronous, so it has to run inside
/// [WidgetTester.runAsync] — the fake async zone a widget test normally uses
/// never completes `toImage`, and the test simply hangs.
Future<Set<int>> renderedColors(WidgetTester tester, Finder finder) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List();
  }))!;

  final colors = <int>{};
  for (var i = 0; i < bytes.length; i += 4) {
    final a = bytes[i + 3];
    if (a < 200) continue; // ignore transparent and antialiased edges
    colors.add((bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]);
  }
  return colors;
}

/// Whether [color] is a plausible sample of TMDB's green-to-blue gradient
/// (#90cea1 → #3cbec9 → #00b3e5).
///
/// The test is for *saturation*, not brightness: every stop has green and/or
/// blue far ahead of red, whereas the grey attribution text is near-neutral.
/// An earlier version of this check only asked for "not much red, some green"
/// and passed on the antialiased text — a false green light for a logo that
/// was not drawn at all.
bool looksLikeTmdbGradient(int color) {
  final r = (color >> 16) & 0xff;
  final g = (color >> 8) & 0xff;
  final b = color & 0xff;
  final strongest = g > b ? g : b;
  return strongest - r > 40;
}

void main() {
  testWidgets('renders the TMDB mark in its own colours, not as black paths',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.surface,
          body: Center(
            child: RepaintBoundary(child: TmdbAttribution()),
          ),
        ),
      ),
    );
    // Decoding the asset is real async work; give it a turn outside the fake
    // async zone, then pump the result into the tree.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text('Metadata provided by TMDB'), findsOneWidget);

    final colors = await renderedColors(
      tester,
      find.byType(RepaintBoundary).first,
    );

    expect(
      colors.any(looksLikeTmdbGradient),
      isTrue,
      reason: 'the logo should paint TMDB green/blue somewhere. If this fails '
          'the paths rendered black (or not at all) and the attribution is '
          'effectively invisible on a dark background.',
    );
  });
}
