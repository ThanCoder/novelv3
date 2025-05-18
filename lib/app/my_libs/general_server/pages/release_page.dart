import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import '../index.dart';

class ReleasePage extends StatelessWidget {
  const ReleasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GeneralServices.instance.getReleaseList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TLoader();
        }
        if (snapshot.hasError) {
          return Text('error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          final list = snapshot.data ?? [];
          return ListView.separated(
            itemBuilder: (context, index) => ReleaseListItem(
              release: list[index],
              onDownloadClicked: (release) async {
                final app = await GeneralServices.instance
                    .getReleaseAppLatestWithPkg(release.packageName);
                if (app == null || app.url.isEmpty) return;
                await ThanPkg.platform.launch(app.url);
              },
            ),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: list.length,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class ReleaseListItem extends StatelessWidget {
  ReleaseModel release;
  void Function(ReleaseModel release) onDownloadClicked;
  ReleaseListItem(
      {super.key, required this.release, required this.onDownloadClicked});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: TImageUrl(url: '$serverProxyUrl?url=${release.coverUrl}'),
        ),
        Expanded(
          child: Column(
            spacing: 3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(release.title),
              // Text(release.packageName),
              release.description.isEmpty
                  ? const SizedBox.shrink()
                  : Text(release.description),
              Text('Date: ${DateTime.parse(release.date).toParseTime()}'),
              Text('Ago: ${DateTime.parse(release.date).toAutoParseTime()}'),
              IconButton(
                onPressed: () => onDownloadClicked(release),
                icon: const Icon(Icons.download),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
