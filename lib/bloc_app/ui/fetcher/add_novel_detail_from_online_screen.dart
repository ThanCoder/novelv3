import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_proxy.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:novel_v3/core/services/novel_services.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';

class AddNovelDetailFromOnlineScreen extends StatefulWidget {
  final NovelItemResult item;
  final FetcherWebsite site;
  final void Function(Novel? createdNovel)? onClosed;
  const AddNovelDetailFromOnlineScreen({
    super.key,
    required this.item,
    required this.site,
    this.onClosed,
  });

  @override
  State<AddNovelDetailFromOnlineScreen> createState() =>
      _AddNovelDetailFromOnlineScreenState();
}

class _AddNovelDetailFromOnlineScreenState
    extends State<AddNovelDetailFromOnlineScreen> {
  @override
  void initState() {
    coverUrl = widget.item.coverUrl;
    super.initState();
    init();
  }

  bool isLoading = false;
  bool isAddLoading = false;
  String coverUrl = '';
  NovelDetailResult? result;
  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });

      result = await FetchServices.instance.fetchNovelDetail(
        widget.item.pageUrl,
        website: widget.site,
      );
      if (coverUrl.isEmpty) {
        coverUrl = result!.coverUrl;
      }

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title, style: TextStyle(fontSize: 13)),
        actions: [FetcherProxyIcon()],
      ),
      body: TScrollableColumn(
        children: [
          SizedBox(width: 180, height: 200, child: TImage(source: coverUrl)),
          _result(),
        ],
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              onPressed: isAddLoading ? null : _addNovel,
              child: isAddLoading ? TLoaderRandom() : Icon(Icons.add),
            ),
    );
  }

  Widget _result() {
    if (isLoading) {
      return Center(child: TLoader.random());
    }
    if (result == null) {
      return Center(child: Text("Result Is Null"));
    }
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title: ${result?.title}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Author: ${result?.author}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Translator: ${result?.translator}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Other Titles: ${result?.otherTitles}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Divider(),
        Text(result!.description),
      ],
    );
  }

  void _addNovel() async {
    try {
      setState(() {
        isAddLoading = true;
      });
      // await Future.delayed(Duration(seconds: 3));
      final newNovel = await NovelServices.instance.createNovel(
        meta: NovelMeta.create(
          title: widget.item.title.isEmpty ? result!.title : widget.item.title,
          author: result!.author,
          desc: result!.description,
          otherTitleList: [result!.otherTitles],
          translator: result!.translator,
          pageUrls: [widget.item.pageUrl],
        ),
      );
      // download cover
      await FetchServices.instance.client.download(
        coverUrl,
        savePath: newNovel.getCoverPath,
      );

      if (!mounted) return;
      setState(() {
        isAddLoading = false;
      });
      showTSnackBar(context, 'Novel ကိုထည့်သွင်းပြီးပါပြီ');
      Navigator.pop(context);
      widget.onClosed?.call(newNovel);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isAddLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }
}
