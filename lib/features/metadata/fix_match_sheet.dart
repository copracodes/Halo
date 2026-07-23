import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/tmdb/models/tmdb_search_result.dart';
import '../../data/tmdb/tmdb_images.dart';
import '../../data/tmdb/tmdb_providers.dart';
import '../../data/tmdb/tmdb_result.dart';

/// Opens the live "Fix match" search and returns the entry the user picked, or
/// null if they dismissed it. [initialQuery] is the parsed title, so the search
/// starts from what Halo read off disk rather than a blank field.
Future<TmdbSearchResult?> showFixMatchSheet(
  BuildContext context, {
  required String initialQuery,
  required bool isMovie,
}) {
  return showModalBottomSheet<TmdbSearchResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _FixMatchSheet(initialQuery: initialQuery, isMovie: isMovie),
  );
}

/// One live search over TMDB, run as the user types, so a wrong match can be
/// corrected by hand. This is one of the few surfaces that reads TMDB images
/// straight from the network: it is an explicitly online action, and its results
/// aren't the offline library — they're candidates the user is choosing between.
class _FixMatchSheet extends ConsumerStatefulWidget {
  const _FixMatchSheet({required this.initialQuery, required this.isMovie});

  final String initialQuery;
  final bool isMovie;

  @override
  ConsumerState<_FixMatchSheet> createState() => _FixMatchSheetState();
}

/// What the results area is currently showing.
enum _Phase { idle, loading, offline, error, results }

class _FixMatchSheetState extends ConsumerState<_FixMatchSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery);
  Timer? _debounce;

  _Phase _phase = _Phase.idle;
  List<TmdbSearchResult> _results = const [];

  /// Rising id so a slow earlier request can't overwrite a newer one's results.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    // The parsed title is almost always what the user wants to search for, so
    // run it immediately rather than making them re-type it.
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _phase = _Phase.idle;
        _results = const [];
      });
      return;
    }

    final id = ++_requestId;
    setState(() => _phase = _Phase.loading);

    final api = ref.read(tmdbApiProvider);
    final result = widget.isMovie
        ? await api.searchMovies(query)
        : await api.searchTv(query);
    if (!mounted || id != _requestId) return;

    setState(() {
      switch (result) {
        case TmdbSuccess(:final value):
          _results = value.results;
          _phase = _Phase.results;
        case TmdbFailure(:final kind):
          _results = const [];
          _phase = (kind == TmdbFailureKind.networkUnavailable ||
                  kind == TmdbFailureKind.timeout)
              ? _Phase.offline
              : _Phase.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isMovie ? 'Find the right film' : 'Find the right show',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      onChanged: _onChanged,
                      onSubmitted: (_) => _search(),
                      autofocus: false,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: widget.isMovie
                            ? 'Search movies on TMDB'
                            : 'Search TV shows on TMDB',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _body(scrollController)),
            ],
          );
        },
      ),
    );
  }

  Widget _body(ScrollController scrollController) {
    switch (_phase) {
      case _Phase.idle:
        return const _Hint(
          icon: Icons.search,
          text: 'Type a title to search TMDB.',
        );
      case _Phase.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      case _Phase.offline:
        return const _Hint(
          icon: Icons.cloud_off,
          text: 'You’re offline. Connect to the internet to search TMDB.',
        );
      case _Phase.error:
        return const _Hint(
          icon: Icons.error_outline,
          text: 'Couldn’t reach TMDB. Try again in a moment.',
        );
      case _Phase.results:
        if (_results.isEmpty) {
          return const _Hint(
            icon: Icons.search_off,
            text: 'No matches. Try a different spelling.',
          );
        }
        final images = ref.read(tmdbApiProvider).images;
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
          itemCount: _results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final result = _results[index];
            return _ResultTile(
              result: result,
              posterUrl: images.poster(result.posterPath, size: PosterSize.w185),
              onTap: () => Navigator.of(context).pop(result),
            );
          },
        );
    }
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result,
    required this.posterUrl,
    required this.onTap,
  });

  final TmdbSearchResult result;
  final String? posterUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final year = result.year;
    final overview = result.overview;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 46,
          height: 69,
          child: posterUrl == null
              ? const ColoredBox(color: AppColors.surface)
              : Image.network(
                  posterUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.surface),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const ColoredBox(color: AppColors.surface);
                  },
                ),
        ),
      ),
      title: Text(
        result.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (year != null)
            Text(
              '$year',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          if (overview != null && overview.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                overview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.75),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
