import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/services/chapter_services.dart';
import 'package:novel_v3/app/services/core/app_services.dart';
import 'package:novel_v3/app/widgets/index.dart';

class ChapterEditForm extends ConsumerStatefulWidget {
  String novelPath;
  ChapterModel? chapter;
  ChapterEditForm({super.key, required this.novelPath, this.chapter});

  @override
  ConsumerState<ChapterEditForm> createState() => _ChapterEditFormState();
}

class _ChapterEditFormState extends ConsumerState<ChapterEditForm> {
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

  final chapterController = TextEditingController();
  final contentController = TextEditingController();

  final chapterFocusNode = FocusNode();
  final contentFocusNode = FocusNode();

  bool isLoading = false;
  bool isChanged = false;
  bool isAutoIncrement = true;
  int chapter = 1;

  void init() async {
    if (widget.chapter != null) {
      chapter = widget.chapter!.number;
      chapterController.text = chapter.toString();
      contentController.text = widget.chapter!.getContent();
      return;
    }
    setState(() {
      isLoading = true;
    });
    chapterController.text = chapter.toString();
    final _chapter = await ChapterServices.instance
        .getLastChapter(novelPath: widget.novelPath);
    if (_chapter != null) {
      chapter = _chapter.number + 1;
      chapterController.text = chapter.toString();
      // contentController.text = _chapter.getContent();
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  String get _getContent {
    if (!_isContentFileExists) return '';
    return File(_getContentPath).readAsStringSync();
  }

  String get _getContentPath {
    return '${widget.novelPath}/$chapter';
  }

  bool get _isContentFileExists {
    return File(_getContentPath).existsSync();
  }

  void _paste() async {
    final res = await pasteFromClipboard();
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
    contentController.text = _getContent;
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
    contentController.text = _getContent;
    if (isShowSubmit) {
      isChanged = true;
    }
    _unFocusAll();
    setState(() {});
  }

  void _save() {
    try {
      // only save
      final ch = ChapterModel(
          title: '', number: chapter, path: '${widget.novelPath}/$chapter');
      ch.setContent(contentController.text);
      ref.read(chapterNotifierProvider.notifier).update(ch.refreshData());

      isChanged = false;
      setState(() {});

      if (isAutoIncrement) {
        _incre(isShowSubmit: false);
      } else {
        _decre(isShowSubmit: false);
      }
    } catch (e) {
      showDialogMessage(context, e.toString());
    }
  }

  void _unFocusAll() {
    chapterFocusNode.unfocus();
    contentFocusNode.unfocus();
  }

  void _backpress() {
    ref.read(chapterNotifierProvider.notifier)
        .initList(novelPath: widget.novelPath, isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _backpress();
      },
      child: MyScaffold(
        contentPadding: 0,
        appBar: AppBar(
          title: const Text('Chapter Form'),
        ),
        body: isLoading
            ? TLoader()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 14,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // chapter
                      TTextField(
                        label: const Text('Chapter Number'),
                        controller: chapterController,
                        textInputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                              Text(isAutoIncrement
                                  ? 'Auto Increment'
                                  : 'Auto Decrement'),
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
                ),
              ),
        floatingActionButton: isChanged
            ? FloatingActionButton(
                onPressed: _save,
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
}
