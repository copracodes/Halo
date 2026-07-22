import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// The official TMDB mark, downloaded from
/// https://www.themoviedb.org/about/logos-attribution.
///
/// It is deliberately the real asset rather than a generated stand-in: TMDB's
/// terms require *their* logo, and an approximation of another organisation's
/// mark would be both non-compliant and misleading.
const String kTmdbLogoAsset = 'assets/tmdb/tmdb_logo.svg';

/// TMDB attribution, as their terms of use require of any app using the API.
class TmdbAttribution extends StatelessWidget {
  const TmdbAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The mark is a fixed-aspect wordmark; height alone sizes it.
          SvgPicture.asset(
            kTmdbLogoAsset,
            height: 14,
            // Never let a missing or malformed asset take a screen down —
            // attribution text alone is better than a crash.
            placeholderBuilder: (_) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Metadata provided by TMDB',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
