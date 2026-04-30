import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/fetch_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/website_services.dart';
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

  @override
  void initState() {
    urlController.text = 'https://mmxianxia.com/novels/blind-sword-master/';
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  List<FetcherWebsite> list = [];
  FetcherWebsite? currentSite;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });

      list = await WebsiteServices.instance.getList();

      // await Future.delayed(Duration(seconds: 2));
      _autoChooseWebsiteType();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
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
          TextButton(
            onPressed: _autoChooseWebsiteType,
            child: Text('Auto Choose Type'),
          ),
          Text('Fetcher Website'),
          _chooserWidget,
          _actionsWidget,
        ],
      ),
    );
  }

  Widget get _chooserWidget {
    if (isLoading) {
      return TLoader();
    }
    return DropdownButton<FetcherWebsite>(
      borderRadius: BorderRadius.circular(4),
      value: currentSite,
      items: list
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
    );
  }

  Widget get _actionsWidget {
    return Padding(
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
    );
  }

  void _autoChooseWebsiteType() {
    final index = list.indexWhere((e) {
      final hostname = Uri.parse(e.url).host;
      final currentHostname = Uri.parse(urlController.text).host;
      return hostname == currentHostname;
    });
    if (index == -1) return;
    currentSite = list[index];
    if (urlController.text.startsWith(currentSite!.hostUrl)) {
      final newUrl =
          '${urlController.text.getCleanBackSlash}${currentSite!.chapterListPageQuery!.autoAddUrlParam}';
      urlController.text = newUrl;
    }
    setState(() {});
  }
}
