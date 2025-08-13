import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

import '../types/pdf_bookmark_model.dart';

class PdfBookmarkDrawer extends StatefulWidget {
  String bookmarkPath;
  int currentPage;
  void Function(int page) onClicked;
  PdfBookmarkDrawer({
    super.key,
    required this.bookmarkPath,
    required this.currentPage,
    required this.onClicked,
  });

  @override
  State<PdfBookmarkDrawer> createState() => _PdfBookmarkDrawerState();
}

class _PdfBookmarkDrawerState extends State<PdfBookmarkDrawer> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  List<PdfBookmarkModel> list = [];

  void init() async {
    setState(() {
      isLoading = true;
    });

    list = await PdfBookmarkModel.getBookmarkListFromPath(widget.bookmarkPath);

    setState(() {
      isLoading = false;
    });
  }

  bool get _isExistsPage {
    final res = list.where((bm) => bm.page == widget.currentPage);
    if (res.isNotEmpty) return true;
    return false;
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5,
      children: [
        TextButton(
          onPressed: _isExistsPage ? null : _add,
          child: const Text('New'),
        ),
        TextButton(
          onPressed: _isExistsPage ? null : _addQuick,
          child: const Text('New Quick'),
        ),
      ],
    );
  }

  void _add() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TRenameDialog(
        text: 'Untitled',
        onSubmit: (text) async {
          final bm = PdfBookmarkModel(title: text, page: widget.currentPage);
          list.add(bm);
          list.sort((a, b) => a.page.compareTo(b.page));
          await PdfBookmarkModel.setBookmarkListFromPath(
            widget.bookmarkPath,
            list,
          );
          if (!context.mounted) return;
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  void _addQuick() async {
    final bm = PdfBookmarkModel(page: widget.currentPage);
    list.add(bm);
    list.sort((a, b) => a.page.compareTo(b.page));
    await PdfBookmarkModel.setBookmarkListFromPath(widget.bookmarkPath, list);
    if (!mounted) return;
    setState(() {});
    Navigator.pop(context);
  }

  void _removePage(int page) async {
    list = list.where((bm) => bm.page != page).toList();
    await PdfBookmarkModel.setBookmarkListFromPath(widget.bookmarkPath, list);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              const SliverToBoxAdapter(child: Divider()),
              SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final bm = list[index];
                  return GestureDetector(
                    onTap: () {
                      if (bm.page == widget.currentPage) return;
                      Navigator.pop(context);
                      widget.onClicked(bm.page);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectionColor: Colors.red,
                              '${bm.page} : ${bm.title}',
                              style: TextStyle(
                                color: bm.page == widget.currentPage
                                    ? const Color.fromARGB(234, 175, 175, 175)
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            color: Colors.red,
                            onPressed: () => _removePage(bm.page),
                            icon: const Icon(Icons.delete_forever),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
