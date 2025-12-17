import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/providers/chapter_provider.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class EditChapterScreen extends StatefulWidget {
  final String novelPath;
  final Chapter? chapter;
  final void Function()? onClosed;
  const EditChapterScreen({
    super.key,
    required this.novelPath,
    this.chapter,
    this.onClosed,
  });

  @override
  State<EditChapterScreen> createState() => _EditChapterScreenState();
}

class _EditChapterScreenState extends State<EditChapterScreen> {
  final chapterController = TextEditingController();
  final contentController = TextEditingController();

  final chapterFocusNode = FocusNode();
  final contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    chapterController.dispose();
    contentController.dispose();

    chapterFocusNode.dispose();
    contentFocusNode.dispose();

    super.dispose();
  }

  bool isLoading = false;
  bool isChanged = false;
  bool isAutoIncrement = true;
  int chapterNumber = 1;
  late ChapterProvider provider;

  void init() async {
    provider = context.read<ChapterProvider>();

    if (widget.chapter != null) {
      chapterNumber = widget.chapter!.number;
      contentController.text = await _getChapterFileContent();
      setState(() {});
    } else {
      setState(() {
        isLoading = true;
      });
      await provider.init(widget.novelPath);
      // set provider list
      chapterNumber = provider.getLatestChapter + 1;
    }
    chapterController.text = chapterNumber.toString();
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _backpress();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Chapter Form')),
        body: isLoading
            ? Center(child: TLoaderRandom())
            : TScrollableColumn(
                children: [
                  // chapter
                  TTextField(
                    label: const Text('Chapter Number'),
                    focusNode: chapterFocusNode,
                    controller: chapterController,
                    textInputType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      if (!isChanged) {
                        setState(() {
                          isChanged = true;
                        });
                      }
                      if (value.isEmpty) return;
                      try {
                        chapterNumber = int.parse(value);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                  ),
                  // row
                  Row(
                    spacing: 5,
                    children: [
                      // auto
                      Row(
                        spacing: 4,
                        children: [
                          Text(
                            isAutoIncrement
                                ? 'Auto Increment'
                                : 'Auto Decrement',
                          ),
                          Switch(
                            value: isAutoIncrement,
                            onChanged: (value) {
                              isAutoIncrement = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),

                      const SizedBox(width: 10),
                      //decre
                      IconButton(
                        onPressed: _decre,
                        icon: const Icon(
                          Icons.remove_circle_outlined,
                          color: Colors.red,
                        ),
                      ),
                      // const SizedBox(width: 10),
                      //incre
                      IconButton(
                        onPressed: _incre,
                        icon: const Icon(
                          Icons.add_circle_outlined,
                          color: Colors.green,
                        ),
                      ),

                      const Spacer(),
                      //paste
                      IconButton(
                        onPressed: _paste,
                        icon: const Icon(Icons.paste_rounded),
                      ),
                    ],
                  ),
                  //content
                  TTextField(
                    label: const Text('Content'),
                    controller: contentController,
                    maxLines: null,
                    focusNode: contentFocusNode,
                    onChanged: (value) {
                      if (!isChanged) {
                        setState(() {
                          isChanged = true;
                        });
                      }
                    },
                  ),
                ],
              ),
        floatingActionButton: isChanged
            ? FloatingActionButton(
                onPressed: _onSave,
                child: Icon(
                  _isContentFileExists
                      ? Icons.save_as_rounded
                      : Icons.add_circle_outlined,
                ),
              )
            : null,
      ),
    );
  }

  bool get _isContentFileExists {
    return provider.isExistsNumber(chapterNumber);
  }

  Future<String> _getChapterFileContent() async {
    return await provider.getContent(
          chapterNumber,
          novelPath: widget.novelPath,
        ) ??
        '';
  }

  Future<void> setChapterContent() async {
    await provider.setChapter(
      Chapter.create(number: chapterNumber, content: contentController.text),
    );
  }

  void _paste() async {
    final res = await ThanPkg.appUtil.pasteText();
    if (res.isEmpty) return;
    contentController.text = res;
    _unFocusAll();
    setState(() {
      isChanged = true;
    });
  }

  void _incre({bool isShowSubmit = true}) async {
    chapterNumber++;
    chapterController.text = chapterNumber.toString();
    contentController.text = await _getChapterFileContent();

    if (isShowSubmit) {
      isChanged = true;
    }
    _unFocusAll();
    setState(() {});
  }

  void _decre({bool isShowSubmit = true}) async {
    if (chapterNumber <= 1) return;
    chapterNumber--;
    chapterController.text = chapterNumber.toString();
    contentController.text = await _getChapterFileContent();
    if (isShowSubmit) {
      isChanged = true;
    }
    _unFocusAll();
    setState(() {});
  }

  void _onSave() async {
    try {
      await setChapterContent();
      isChanged = false;
      if (!mounted) return;

      setState(() {});
      _unFocusAll();

      if (isAutoIncrement) {
        _incre(isShowSubmit: false);
      } else {
        _decre(isShowSubmit: false);
      }
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }

  void _unFocusAll() {
    chapterFocusNode.unfocus();
    contentFocusNode.unfocus();
  }

  void _backpress() {
    if (!isChanged) return;
    widget.onClosed?.call();
  }
}
