import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../player/play_media.dart';

/// Collapsed shelf for files the parser couldn't classify as a movie or an
/// episode. They're still playable — nothing in the user's library is allowed to
/// be invisible just because its filename was unusual.
class OtherFilesSection extends StatelessWidget {
  const OtherFilesSection({super.key, required this.files});

  final List<MediaFile> files;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Keep the expansion divider lines out of the dark, borderless look.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        title: const Text(
          'Other files',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${files.length} file${files.length == 1 ? '' : 's'} we couldn’t '
          'identify',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        children: [
          for (final file in files)
            ListTile(
              dense: true,
              leading: const Icon(
                Icons.insert_drive_file_outlined,
                color: AppColors.textSecondary,
              ),
              title: Text(
                file.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              onTap: () => playMediaFile(context, file),
            ),
        ],
      ),
    );
  }
}
