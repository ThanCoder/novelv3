import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/services/dio_services.dart';
import 'package:novel_v3/app/services/html_dom_services.dart';
import 'package:novel_v3/app/widgets/index.dart';

class DescriptionOnlineFetcherDialog extends StatefulWidget {
  void Function(String text) onFetched;
  DescriptionOnlineFetcherDialog({
    super.key,
    required this.onFetched,
  });

  @override
  State<DescriptionOnlineFetcherDialog> createState() =>
      _DescriptionOnlineFetcherDialogState();
}

class _DescriptionOnlineFetcherDialogState
    extends State<DescriptionOnlineFetcherDialog> {
  final urlController = TextEditingController();
  final queryController = TextEditingController();
  final resultController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    urlController.text =
        'https://mmxianxia.com/novels/who-let-him-cultivate-immortality';
    queryController.text = '.sersysn';
  }

  void _fetch() async {
    if (urlController.text.isEmpty && queryController.text.isEmpty) {
      showDialogMessage(context, 'ပြည့်စုံအောင် ဖြည့်သွင်းပေးပါ');
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final res = await DioServices.instance.getDio.get(urlController.text);
      final ele = HtmlDomServices.getHtmlEle(res.data.toString());
      if (ele == null) return;
      final html = HtmlDomServices.getQuerySelectorHtml(
        ele,
        queryController.text,
      );

      if (!mounted) return;
      resultController.text =
          HtmlDomServices.getNewLine(html, replacer: '\n\n');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TTextField(
            controller: urlController,
            label: const Text('Website Url'),
            isSelectedAll: true,
          ),
          TTextField(
            controller: queryController,
            label: const Text('Query'),
            isSelectedAll: true,
          ),
          isLoading
              ? TLoader(
                  size: 30,
                )
              : IconButton(
                  onPressed: _fetch,
                  icon: const Icon(Icons.download),
                ),
          resultController.text.isEmpty
              ? const SizedBox.shrink()
              : TTextField(
                  controller: resultController,
                  maxLines: null,
                  label: const Text('Result'),
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onFetched(resultController.text);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
