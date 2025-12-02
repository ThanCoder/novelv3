import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/querys/desc_query.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/selector_rules.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/soup_extractor.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/desc_query_types.dart';
import 'package:than_pkg/than_pkg.dart';
import '../fetcher.dart';
import 'package:t_widgets/t_widgets.dart';

typedef ReceiveCallback =
    void Function(BuildContext context, String description);

class FetcherDescScreen extends StatefulWidget {
  final ReceiveCallback? onReceiveData;
  final VoidCallback? onClosed;
  final String? url;
  const FetcherDescScreen({
    super.key,
    this.url,
    this.onReceiveData,
    this.onClosed,
  });

  @override
  State<FetcherDescScreen> createState() => _FetcherDescScreenState();
}

class _FetcherDescScreenState extends State<FetcherDescScreen> {
  final urlController = TextEditingController();
  final descController = TextEditingController();
  // focus
  final urlFocus = FocusNode();
  final descFocus = FocusNode();

  DescQueryTypes fetcherType = DescQueryTypes.mmxianxia;
  final List<DescQuery> queryList = [
    DescQuery(
      startHostUrl: 'https://msunmm.com',
      title: 'Mmxianxia description',
      type: DescQueryTypes.mmxianxia,
      selector: '.entry-content',
    ),
    DescQuery(
      startHostUrl: 'https://mmxianxia.com',
      title: 'Msunmm description',
      type: DescQueryTypes.msunmm,
      selector: '.entry-content',
    ),
  ];

  @override
  void initState() {
    urlController.text = widget.url ?? '';
    super.initState();
    _onFetch();
  }

  @override
  void dispose() {
    urlController.dispose();
    descController.dispose();
    urlFocus.dispose();
    descFocus.dispose();
    super.dispose();
  }

  bool isLoading = false;
  bool autoIncreChapter = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onClosed?.call(),
        );
      },
      child: TScaffold(
        appBar: AppBar(title: Text('Fetcher')),
        body: TScrollableColumn(
          children: [
            _getTitleWidget(),
            Text('Fetcher Types'),
            _getTypeChooser(),
            Divider(),
            Text('Result'),
            TTextField(
              label: Text('Description'),
              controller: descController,
              maxLines: null,
              focusNode: descFocus,
            ),
          ],
        ),
        floatingActionButton: isLoading
            ? Center(child: TLoaderRandom())
            : Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'fetch',
                    onPressed: _onFetch,
                    child: Icon(Icons.cloud_download_outlined),
                  ),
                  FloatingActionButton(
                    heroTag: 'save',
                    onPressed: _onSave,
                    child: Icon(Icons.save_as_rounded),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _getTitleWidget() {
    return Row(
      children: [
        Expanded(
          child: TTextField(
            label: Text('Host Url'),
            controller: urlController,
            maxLines: 1,
            isSelectedAll: true,
            onChanged: _onFetcherTypeAutoChanger,
            focusNode: urlFocus,
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          onPressed: () async {
            try {
              urlController.text = await ThanPkg.appUtil.pasteText();
              _onFetcherTypeAutoChanger(urlController.text);
              _onFetch();
            } catch (e) {
              Fetcher.showDebugLog(e.toString());
            }
          },
          icon: Icon(Icons.paste_rounded),
        ),
      ],
    );
  }

  Widget _getTypeChooser() {
    return DropdownButton<DescQueryTypes>(
      borderRadius: BorderRadius.circular(4),
      padding: EdgeInsets.all(4),
      value: fetcherType,
      items: DescQueryTypes.values
          .map(
            (e) => DropdownMenuItem<DescQueryTypes>(
              value: e,
              child: Text(e.name.toCaptalize()),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          fetcherType = value!;
        });
      },
    );
  }

  void _onFetcherTypeAutoChanger(String text) {
    if (text.isEmpty) return;
    for (var query in queryList) {
      if (text.startsWith(query.startHostUrl) && fetcherType != query.type) {
        setState(() {
          fetcherType = query.type;
        });
        break;
      }
    }
  }

  void _onSave() {
    if (descController.text.isEmpty) {
      Fetcher.instance.showErrorMessage(
        context,
        'Description ထဲမှာ `text` ရှိရပါမယ်!',
      );
      return;
    }
    Navigator.pop(context);

    widget.onReceiveData?.call(context, descController.text);

    // descController.text = '';
    // clear focus
    // _clearFocus();
  }

  void _onFetch() async {
    try {
      if (urlController.text.isEmpty) return;
      setState(() {
        isLoading = true;
      });

      final content = await Fetcher.instance.onGetHtmlContent(
        urlController.text,
      );
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (content.isEmpty) {
        throw Exception('HTML Text Content မရှိပါ');
      }
      _onFetchWthType(content);
    } catch (e) {
      Fetcher.showDebugLog(e.toString(), tag: 'FetcherDescScreen:_onFetch');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      Fetcher.instance.showErrorMessage(context, e.toString());
    }
  }

  void _onFetchWthType(String content) {
    try {
      final fetcher = queryList.where((e) => e.type == fetcherType).first;
      final extractor = SoupExtractor(
        rules: {fetcher.title: SelectorRules(fetcher.selector)},
      );
      final map = extractor.extract(content);
      if (map[fetcher.title] == null) throw Exception('[fetcher.title] null!');

      final text = map[fetcher.title] ?? '';
      descController.text = text.trim();
    } catch (e) {
      Fetcher.showDebugLog(e.toString(), tag: 'FetcherDescScreen:_onFetchType');
      if (!mounted) return;
      Fetcher.instance.showErrorMessage(context, e.toString());
    }
  }
}
