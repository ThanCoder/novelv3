import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:t_release/models/t_release_version_model.dart';

class ReleaseListItem extends StatelessWidget {
  TReleaseVersionModel release;
  void Function(TReleaseVersionModel release) onClicked;
  ReleaseListItem({
    super.key,
    required this.release,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Version: ${release.version}'),
        Text('Platform: ${release.platform}'),
        Text(DateTime.fromMillisecondsSinceEpoch(release.date).toTimeAgo()),
        release.description.isNotEmpty
            ? Text(release.description)
            : const SizedBox.shrink(),
        release.url.isNotEmpty
            ? Text('Url: ${release.url}')
            : const SizedBox.shrink(),
        release.url.isNotEmpty
            ? IconButton(
                onPressed: () => onClicked(release),
                icon: const Icon(Icons.download),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
