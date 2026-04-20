import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/fetch_website.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:t_widgets/t_widgets.dart';

class FetcherSupportedSiteDialog extends StatefulWidget {
  final void Function(FetcherWebsite site) onChoosed;
  const FetcherSupportedSiteDialog({super.key, required this.onChoosed});

  @override
  State<FetcherSupportedSiteDialog> createState() =>
      _FetcherSupportedSiteDialogState();
}

class _FetcherSupportedSiteDialogState
    extends State<FetcherSupportedSiteDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  List<FetcherWebsite> list = [];

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      list = await FetchServices.instance.getWebsiteList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text('ရယူနိုင်သော Website များ'),
      scrollable: true,
      content: isLoading
          ? Center(child: TLoader())
          : list.isEmpty
          ? IconButton(onPressed: init, icon: Icon(Icons.refresh))
          : SizedBox(
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
