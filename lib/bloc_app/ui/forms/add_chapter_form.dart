import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/core/databases/chapter_db.dart';
import 'package:novel_v3/core/extensions/chapter_extension.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

enum _PasteType { add, append, preAppend }

class AddChapterForm extends StatefulWidget {
  final Novel novel;
  final Chapter? currentChapter;
  final void Function()? onClosed;
  const AddChapterForm({
    super.key,
    required this.novel,
    this.currentChapter,
    this.onClosed,
  });

  static bool initiallyExpanded = false;

  @override
  State<AddChapterForm> createState() => _AddChapterFormState();
}

class _AddChapterFormState extends State<AddChapterForm> {
  final chapterController = TextEditingController();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final chapterFocusNode = FocusNode();
  final contentFocusNode = FocusNode();
  late ChapterListCubit _chapterListCubit;
  List<Chapter> allList = [];

  @override
  void initState() {
    _chapterListCubit = context.read<ChapterListCubit>();
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

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });

      allList.addAll(_chapterListCubit.state.list);
      allList.sortChapterNumber();

      if (widget.currentChapter != null) {
        chapterNumber = widget.currentChapter!.number;
        titleController.text = widget.currentChapter!.title;
        contentController.text = await _getChapterFileContent();
      } else {
        chapterNumber = allList.isNotEmpty ? allList.last.number + 1 : 1;
      }
      chapterController.text = chapterNumber.toString();
      _setTitleFromContent();

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

  bool isLoading = false;
  bool isChapterContentLoading = false;
  bool isChanged = false;
  bool isAutoIncrement = true;
  int chapterNumber = 1;
  int readTitleLine = -1;
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
                spacing: 15,
                children: [
                  // chapter
                  _getChapterNumberWidget(),
                  // title
                  _getTitleWidget(),
                  //content
                  _getContentWidet(),
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

  Widget _getChapterNumberWidget() {
    return Column(
      children: [
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
        SizedBox(width: 20),
        // row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 5,
            children: [
              // auto
              Row(
                spacing: 4,
                children: [
                  Text(isAutoIncrement ? 'Auto Increment' : 'Auto Decrement'),
                  Switch(
                    value: isAutoIncrement,
                    onChanged: (value) {
                      isAutoIncrement = value;
                      isChanged = true;
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _getTitleWidget() {
    return Column(
      spacing: 4,
      children: [
        TTextField(
          label: Text('Title'),
          controller: titleController,
          maxLines: 1,
          onChanged: (value) {
            isChanged = true;
            setState(() {});
          },
        ),
        ExpansionTile(
          initiallyExpanded: AddChapterForm.initiallyExpanded,
          onExpansionChanged: (value) =>
              AddChapterForm.initiallyExpanded = value,
          title: Text('Content ထဲကနေ Title ရယူမယ်'),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Line: $readTitleLine',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    if (readTitleLine == -1) return;
                    readTitleLine--;
                    isChanged = true;
                    setState(() {});
                    _setTitleFromContent();
                  },
                  icon: Icon(Icons.remove_circle, color: Colors.amber),
                ),
                IconButton(
                  onPressed: () {
                    readTitleLine++;
                    isChanged = true;
                    setState(() {});
                    _setTitleFromContent();
                  },
                  icon: Icon(Icons.add_circle, color: Colors.teal),
                ),
                SizedBox(width: 20),
              ],
            ),
            // info
            Text('Line [-1]: Off'),
            Text('Line [number]: Content ထဲကနေ Title ကိုရယူမယ်'),
          ],
        ),
      ],
    );
  }

  Widget _getContentWidet() {
    return Column(
      children: [
        _getPasteWidget(),
        if (isChapterContentLoading)
          Center(child: TLoader.random())
        else
          TTextField(
            label: const Text('Main Content'),
            controller: contentController,
            maxLines: null,
            focusNode: contentFocusNode,
            onChanged: (value) {
              _setTitleFromContent();
              if (!isChanged) {
                setState(() {
                  isChanged = true;
                });
              }
            },
          ),
        SizedBox(height: 60),
      ],
    );
  }

  Widget _getPasteWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Pre Append'),
          IconButton(
            onPressed: () => _paste(pasteType: _PasteType.preAppend),
            icon: const Icon(Icons.paste_rounded, color: Colors.blue),
          ),
          SizedBox(width: 10),
          Text('Append'),
          IconButton(
            onPressed: () => _paste(pasteType: _PasteType.append),
            icon: const Icon(Icons.paste_rounded, color: Colors.blue),
          ),
          SizedBox(width: 40),
          Text('SetAll'),
          IconButton(
            onPressed: _paste,
            icon: const Icon(Icons.paste_rounded, color: Colors.blue),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }

  bool get _isContentFileExists {
    return allList.indexWhere((e) => e.number == chapterNumber) != -1;
  }

  Future<String> _getChapterFileContent() async {
    setState(() {
      isChapterContentLoading = true;
    });
    final res = await _chapterListCubit.getChapterContent(chapterNumber);
    setState(() {
      isChapterContentLoading = false;
    });
    return res ?? '';
  }

  void _paste({_PasteType pasteType = _PasteType.add}) async {
    final res = await ThanPkg.appUtil.pasteText();
    if (res.isEmpty) return;
    final buff = StringBuffer();

    switch (pasteType) {
      case _PasteType.add:
        buff.write(res.trim());
        break;
      case _PasteType.append:
        buff.writeln(contentController.text);
        buff.writeln(res);

        break;
      case _PasteType.preAppend:
        buff.write(res);
        buff.writeln(contentController.text);
        break;
    }
    contentController.text = buff.toString().trim();
    _setTitleFromContent();
    _unFocusAll();
    if (!mounted) return;

    setState(() {
      isChanged = true;
    });
    showTSnackBar(context, pasteType.name);
  }

  void _incre({bool isShowSubmit = true}) async {
    if (isChapterContentLoading) return;
    chapterNumber++;
    chapterController.text = chapterNumber.toString();
    contentController.text = await _getChapterFileContent();
    _setTitleFromContent();
    if (isShowSubmit) {
      isChanged = true;
    }
    _unFocusAll();
    setState(() {});
  }

  void _decre({bool isShowSubmit = true}) async {
    if (isChapterContentLoading) return;
    if (chapterNumber <= 1) return;
    chapterNumber--;
    chapterController.text = chapterNumber.toString();
    contentController.text = await _getChapterFileContent();
    _setTitleFromContent();
    if (isShowSubmit) {
      isChanged = true;
    }
    _unFocusAll();
    setState(() {});
  }

  void _setTitleFromContent() {
    if (readTitleLine == -1 || contentController.text.isEmpty) {
      final index = allList.indexWhere((e) => e.number == chapterNumber);
      final title = index == -1 ? null : allList[index].title;
      titleController.text = title ?? 'Untitled';
      return;
    }
    final contentList = contentController.text.split('\n');
    if (readTitleLine > contentList.length) return;

    titleController.text = contentList[readTitleLine];
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

  Future<void> setChapterContent() async {
    try {
      final chapter = Chapter.create(
        title: titleController.text,
        number: chapterNumber,
        novelId: widget.novel.id,
        content: contentController.text,
      );
      final (isAdded, _) = await _chapterListCubit.addOrUpdate(chapter);

      if (isAdded) {
        allList.add(chapter);
        allList.sortChapterNumber();
        setState(() {});
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
    ChapterDB.clear(widget.novel.id);
    if (!isChanged) return;
    widget.onClosed?.call();
  }
}
