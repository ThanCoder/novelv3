import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/fetch_website.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';

class FetcherSupportedSiteDialog extends StatefulWidget {
  final void Function(FetcherWebsite site) onChoosed;
  const FetcherSupportedSiteDialog({super.key, required this.onChoosed});

  @override
  State<FetcherSupportedSiteDialog> createState() =>
      _FetcherSupportedSiteDialogState();
}

class _FetcherSupportedSiteDialogState
    extends State<FetcherSupportedSiteDialog> {
  final list = FetchServices.instance.fetcherWebsiteList();

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text('ရယူနိုင်သော Website များ'),
      scrollable: true,
      content: SizedBox(
        height: 200,
        width: 200,
        child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              title: Text(item.title),
              onTap: () {
                context.closeNavigator();
                widget.onChoosed(item);
              },
            );
          },
        ),
      ),
    );
  }
}
