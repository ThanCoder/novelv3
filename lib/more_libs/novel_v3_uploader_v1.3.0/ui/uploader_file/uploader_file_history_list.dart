import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets_dev.dart';

import '../../novel_v3_uploader.dart';

class UploaderFileHistoryPage extends StatefulWidget {
  final bool isApiList;
  final void Function(UploaderFile file)? onClicked;
  const UploaderFileHistoryPage({
    super.key,
    this.isApiList = false,
    this.onClicked,
  });

  @override
  State<UploaderFileHistoryPage> createState() =>
      _UploaderFileHistoryPageState();
}

class _UploaderFileHistoryPageState extends State<UploaderFileHistoryPage>
    with DatabaseListener {
  @override
  void initState() {
    UploaderFileServices.getLocalHistoryDatabase.addListener(this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    UploaderFileServices.getLocalHistoryDatabase.removeListener(this);
    super.dispose();
  }

  @override
  void onDatabaseChanged(String? id, DatabaseListenerTypes listenerType) {
    if (!mounted) return;
    init();
  }

  List<UploaderFile> list = [];
  bool isLoading = false;

  void init() async {
    try {
      if (widget.isApiList) {
        list = await UploaderFileServices.getApiHistoryDatabase.getAll();
      } else {
        list = await UploaderFileServices.getLocalHistoryDatabase.getAll();
      }
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('[UploaderFileHistoryPage:init]: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TSeeAllView<UploaderFile>(
      title: 'Content Files အသစ်များ',
      list: list,
      gridItemBuilder: (context, item) => _getGridItem(item),
    );
  }

  Widget _getNovelWidget(UploaderFile item) {
    return FutureBuilder(
      future: widget.isApiList
          ? NovelServices.getApiDatabase.getById(item.novelId)
          : NovelServices.getLocalDatabase.getById(item.novelId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          return TImage(source: data.coverPath);
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _getGridItem(UploaderFile item) {
    return GestureDetector(
      onTap: () => widget.onClicked?.call(item),
      child: Stack(
        children: [
          Positioned.fill(child: _getNovelWidget(item)),
          Positioned(
            right: 0,
            child: Text(item.type.name, style: TextStyle(fontSize: 11)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
