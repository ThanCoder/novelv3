import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/utils.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class AddChapterFromOnlineScreen extends StatefulWidget {
  final Novel novel;
  final void Function(FetcherWebsiteResult result)? onSaved;
  const AddChapterFromOnlineScreen({
    super.key,
    required this.novel,
    this.onSaved,
  });

  @override
  State<AddChapterFromOnlineScreen> createState() =>
      _AddChapterFromOnlineScreenState();
}

class _AddChapterFromOnlineScreenState
    extends State<AddChapterFromOnlineScreen> {
  @override
  initState() {
    urlController.text = 'https://mmxianxia.com/chapters/1392176/';
    super.initState();
    currentSite = list.first;
    setState(() {});
  }

  @override
  void dispose() {
    urlController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  final urlController = TextEditingController();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  bool isLoading = false;
  final list = FetchServices.instance.fetcherWebsiteList();
  FetcherWebsite? currentSite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Chapter From Online')),
      body: TScrollableColumn(
        children: [
          Row(
            children: [
              Expanded(
                child: TTextField(
                  label: Text('Web Url'),
                  controller: urlController,
                ),
              ),
              IconButton(onPressed: _pasteUrl, icon: Icon(Icons.paste_rounded)),
            ],
          ),
          _supportedSite(),
          // content
          TTextField(label: Text('Title'), controller: titleController),
          TTextField(
            label: Text('Content'),
            controller: contentController,
            maxLines: null,
          ),
        ],
      ),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget _supportedSite() {
    return DropdownButton<FetcherWebsite>(
      value: currentSite,
      items: list
          .map(
            (e) => DropdownMenuItem<FetcherWebsite>(
              value: e,
              child: Text(e.title),
            ),
          )
          .toList(),
      onChanged: (value) {},
    );
  }

  Widget? _floatingActionButton() {
    if (isLoading) {
      return FloatingActionButton(
        onPressed: null,
        child: TLoader.random(size: 30),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 7,
      children: [
        FloatingActionButton(
          heroTag: 'fetch',
          onPressed: _fetch,
          child: Icon(Icons.downloading_sharp),
        ),
        FloatingActionButton(
          heroTag: 'save',
          onPressed: () {
            if (widget.onSaved != null) {
              context.closeNavigator();
            }
            widget.onSaved?.call(
              FetcherWebsiteResult(
                title: titleController.text,
                content: contentController.text,
              ),
            );
          },
          child: Icon(Icons.save_as_rounded),
        ),
      ],
    );
  }

  void _pasteUrl() async {
    try {
      final text = await ThanPkg.appUtil.pasteText();
      if (text.isEmpty) return;
      if (!mounted) return;
      if (!text.startsWith('http')) {
        showTMessageDialogError(context, 'Url မဟုတ်ပါ\n\n`$text`');
        return;
      }
      urlController.text = text;
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  void _fetch() async {
    try {
      if (currentSite == null) {
        showTMessageDialogError(context, 'Site တစ်ခုကို ရွေးချယ်ပါ');
        return;
      }
      setState(() {
        isLoading = true;
      });

      final res = await FetchServices.instance.fetchHtml(
        urlController.text,
        website: currentSite!,
      );
      titleController.text = res.title;
      contentController.text = res.content;

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
}
