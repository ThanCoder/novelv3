import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import '../../novel_dir_app.dart';

class EditChapterScreen extends StatefulWidget {
  String novelPath;
  Chapter? chapter;
  EditChapterScreen({super.key, required this.novelPath, this.chapter});

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
    init();
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
  int chapter = 1;

  void init() async {
    if (widget.chapter != null) {
      chapter = widget.chapter!.number;
    } else {
      // set provider list
      final list = context.read<ChapterProvider>().getList;
      if (list.isNotEmpty) {
        chapter = list.last.number + 1;
      }
    }
    chapterController.text = chapter.toString();

    setState(() {});
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
                        chapter = int.parse(value);
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
    final file = File('${widget.novelPath}/$chapter');
    return file.existsSync();
  }

  String get _getChapterFileContent {
    final file = File('${widget.novelPath}/$chapter');
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
    return '';
  }

  Future<void> setChapterContent() async {
    final file = File('${widget.novelPath}/$chapter');
    await file.writeAsString(contentController.text);
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

  void _incre({bool isShowSubmit = true}) {
    chapter++;
    chapterController.text = chapter.toString();
    contentController.text = _getChapterFileContent;

    if (isShowSubmit) {
      isChanged = true;
    }
    _unFocusAll();
    setState(() {});
  }

  void _decre({bool isShowSubmit = true}) {
    if (chapter <= 1) return;
    chapter--;
    chapterController.text = chapter.toString();
    contentController.text = _getChapterFileContent;
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
      NovelDirApp.showDebugLog(e.toString());
    }
  }

  void _unFocusAll() {
    chapterFocusNode.unfocus();
    contentFocusNode.unfocus();
  }

  void _backpress() {
    context.read<ChapterProvider>().initList(widget.novelPath);
  }
}
