import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/tmdb/models/tmdb_search_result.dart';
import '../../data/tmdb/tmdb_providers.dart';
import '../../data/tmdb/tmdb_result.dart';

/// TEMPORARY (Phase 3.1 device pass).
///
/// Fires one live `search/tv` against TMDB and shows the raw top results, so a
/// real token can be verified on a real device and network before any
/// enrichment is built on top of it. Reached by long-pressing the settings
/// icon; there is no other route to it. Delete once 3.2 wires real enrichment.
class TmdbDebugDialog extends ConsumerStatefulWidget {
  const TmdbDebugDialog({super.key, this.query = 'Westworld'});

  final String query;

  @override
  ConsumerState<TmdbDebugDialog> createState() => _TmdbDebugDialogState();
}

class _TmdbDebugDialogState extends ConsumerState<TmdbDebugDialog> {
  TmdbResult<TmdbSearchPage>? _result;
  String? _imageBase;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() => _result = null);
    final api = ref.read(tmdbApiProvider);
    // Exercises the configuration endpoint too, so the device pass proves both
    // the auth header and the image base URL in one go.
    await api.loadConfiguration();
    final result = await api.searchTv(widget.query);
    if (!mounted) return;
    setState(() {
      _result = result;
      _imageBase = api.images.secureBaseUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.read(tmdbApiProvider);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('TMDB: "${widget.query}"'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Line('token configured', api.hasToken ? 'yes' : 'NO'),
              if (_imageBase != null) _Line('image base', _imageBase!),
              const Divider(height: 20),
              ..._body(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _run, child: const Text('Retry')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  List<Widget> _body() {
    final result = _result;
    if (result == null) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ];
    }

    switch (result) {
      case TmdbFailure(:final kind, :final message, :final statusCode):
        return [
          _Line('result', 'FAILED — ${kind.name}'),
          if (statusCode != null) _Line('status', '$statusCode'),
          if (message != null) _Line('detail', message),
        ];
      case TmdbSuccess(:final value):
        if (value.isEmpty) return const [Text('No results.')];
        return [
          _Line('total results', '${value.totalResults}'),
          const SizedBox(height: 8),
          for (final item in value.results.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.title} (${item.year ?? '—'})',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'id ${item.id} · ★ ${item.voteAverage.toStringAsFixed(1)} '
                    '· poster ${item.posterPath ?? 'none'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ];
    }
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
