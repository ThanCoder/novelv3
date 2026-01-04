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
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final chapterFocusNode = FocusNode();
  final contentFocusNode = FocusNode();

  @override
  void initState() {
    provider = context.read<ChapterProvider>();
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
  int readTitleLine = -1;
  late ChapterProvider provider;

  void init() async {
    if (widget.chapter != null) {
      chapterNumber = widget.chapter!.number;
      titleController.text = widget.chapter!.title;
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
    _setTitleFromContent();

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
          SizedBox(width: 20),
          Text('Append'),
          IconButton(
            onPressed: () => _paste(pasteType: _PasteType.append),
            icon: const Icon(Icons.paste_rounded, color: Colors.blue),
          ),
          SizedBox(width: 50),
          Text('SetAll'),
          IconButton(
            onPressed: _paste,
            icon: const Icon(Icons.paste_rounded, color: Colors.blue),
          ),
          SizedBox(width: 20),
        ],
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
      final chapter = context.read<ChapterProvider>().getOne(
        (chapter) => chapter.number == chapterNumber,
      );
      titleController.text = chapter == null ? 'Untitled' : chapter.title;
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
    final foundCh = provider.getOne((ch) => ch.number == chapterNumber);
    if (foundCh == null) {
      await provider.add(
        Chapter.create(
          title: titleController.text,
          number: chapterNumber,
          content: contentController.text,
        ),
      );
    } else {
      // update
      await provider.update(
        Chapter(
          autoId: foundCh.autoId,
          title: titleController.text,
          number: chapterNumber,
          content: contentController.text,
          date: DateTime.now(),
        ),
      );
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

enum _PasteType { add, append, preAppend }
