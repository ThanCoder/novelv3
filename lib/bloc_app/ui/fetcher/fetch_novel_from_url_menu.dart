import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:t_widgets/t_widgets.dart';

class FetchNovelFromUrlMenu extends StatefulWidget {
  final void Function(String url, FetcherWebsite site) onApply;
  const FetchNovelFromUrlMenu({super.key, required this.onApply});

  @override
  State<FetchNovelFromUrlMenu> createState() => _FetchNovelFromUrlMenuState();
}

class _FetchNovelFromUrlMenuState extends State<FetchNovelFromUrlMenu> {
  final urlController = TextEditingController();
  final siteList = FetchServices.instance.fetcherWebsiteList();
  FetcherWebsite? currentSite;

  @override
  void initState() {
    currentSite = siteList.first;
    urlController.text = 'https://mmxianxia.com/novels/blind-sword-master/';
    super.initState();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: TScrollableColumn(
        children: [
          TTextField(
            label: Text('Web Url'),
            maxLines: 1,
            isSelectedAll: true,
            controller: urlController,
          ),
          Text('Fetcher Website'),
          DropdownButton<FetcherWebsite>(
            borderRadius: BorderRadius.circular(4),
            value: currentSite,
            items: siteList
                .map(
                  (e) => DropdownMenuItem<FetcherWebsite>(
                    value: e,
                    child: Text(e.title),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                currentSite = value;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    context.closeNavigator();
                  },
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    context.closeNavigator();
                    widget.onApply(urlController.text, currentSite!);
                  },
                  child: Text('Apply'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
