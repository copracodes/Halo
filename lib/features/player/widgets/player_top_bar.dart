import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player_controller.dart';

/// Top control bar: back button and the video title. The readability scrim is
/// drawn edge-to-edge by the overlay; this bar is just the content.
class PlayerTopBar extends ConsumerWidget {
  const PlayerTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(
      playerControllerProvider.select((s) => s.title),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
