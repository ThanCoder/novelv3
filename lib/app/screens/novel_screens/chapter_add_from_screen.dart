import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/core/app_services.dart';
import 'package:provider/provider.dart';

import '../../provider/index.dart';
import '../../widgets/index.dart';

class ChapterAddFromScreen extends StatefulWidget {
  const ChapterAddFromScreen({super.key});

  @override
  State<ChapterAddFromScreen> createState() => _ChapterAddFromScreenState();
}

class _ChapterAddFromScreenState extends State<ChapterAddFromScreen> {
  TextEditingController chapterTextController = TextEditingController();
  TextEditingController bodyTextController = TextEditingController();
  bool isIncrement = true;
  bool isChapterExists = false;
  int chapterNumber = 1;
  String? chapterErrorText;

  @override
  void initState() {
    chapterTextController.text = '1';
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() async {
    try {
      await context.read<ChapterProvider>().initList();

      if (!mounted) return;
      int lastChapter =
          await context.read<ChapterProvider>().getLastChapterNumber();
      chapterNumber = lastChapter + 1;
      chapterTextController.text = chapterNumber.toString();
    } catch (e) {
      debugPrint('init: ${e.toString()}');
    }
  }

  void checkIsExistsChapter() {
    final res = context
        .read<ChapterProvider>()
        .getList
        .where((c) => c.title == chapterNumber.toString())
        .toList();
    if (res.isEmpty) {
      setState(() {
        chapterErrorText = null;
        isChapterExists = false;
      });
    } else {
      setState(() {
        chapterErrorText = 'ရှိနေပြီးသား ဖြစ်နေပါတယ်!';
        isChapterExists = true;
      });
    }
  }

  void existsChapterConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('အတည်ပြုခြင်း'),
        content: const Text(
            'chapter content ရှိနေပါတယ်။သင်က ရှိနေပြီးသားကို override လုပ်ချင်ပါသလား?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              addAndAutoIncrementChapter();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void addChapter() {
    if (chapterErrorText != null) {
      //exists chapter
      existsChapterConfirm();
      return;
    }
    //no exists
    addAndAutoIncrementChapter();
  }

  void addAndAutoIncrementChapter() {
    try {
      if (currentNovelNotifier.value == null) return;
      final chapterPath = '${currentNovelNotifier.value!.path}/$chapterNumber';
      final chapterFile = File(chapterPath);
      chapterFile.writeAsStringSync(bodyTextController.text);
      //update ui
      final newChapter = ChapterModel(
          title: chapterPath.getName(withExt: false), path: chapterPath);
      context.read<ChapterProvider>().add(chapter: newChapter);

      if (isIncrement) {
        setState(() {
          chapterNumber++;
        });
      } else {
        if (chapterNumber == 0) return;
        setState(() {
          chapterNumber--;
        });
      }
      bodyTextController.text = '';
      chapterTextController.text = chapterNumber.toString();
      checkIsExistsChapter();
    } catch (e) {
      debugPrint('addAndAutoIncrementChapter: ${e.toString()}');
    }
  }

  void getChapterContent() {
    final chapterPath = '${currentNovelNotifier.value!.path}/$chapterNumber';
    final chapterFile = File(chapterPath);
    if (chapterFile.existsSync()) {
      bodyTextController.text = chapterFile.readAsStringSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ChapterProvider>().isLoading;
    return MyScaffold(
      contentPadding: 5,
      appBar: AppBar(
        title: const Text('Add New Chapter'),
        actions: [
          IconButton(
            onPressed: addChapter,
            icon: const Icon(Icons.add_circle_rounded),
          ),
        ],
      ),
      body: isLoading
          ? TLoader()
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    TTextField(
                      isSelectedAll: true,
                      controller: chapterTextController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputType: TextInputType.number,
                      label: const Text('Chapter Number'),
                      errorText: chapterErrorText,
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        try {
                          chapterNumber = int.parse(value);
                          checkIsExistsChapter();
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                    ),
                    //header
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              bodyTextController.text =
                                  await pasteFromClipboard();
                            },
                            icon: const Icon(Icons.paste),
                          ),
                          //increment chapter
                          IconButton(
                            onPressed: () {
                              chapterNumber++;
                              setState(() {
                                chapterTextController.text =
                                    chapterNumber.toString();
                              });
                              checkIsExistsChapter();
                            },
                            icon: const Icon(Icons.add),
                          ),
                          const SizedBox(width: 10),
                          //decrement chapter
                          IconButton(
                            onPressed: () {
                              if (chapterNumber == 0) return;
                              chapterNumber--;
                              setState(() {
                                chapterTextController.text =
                                    chapterNumber.toString();
                              });
                              checkIsExistsChapter();
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          const SizedBox(width: 10),
                          //increment switch
                          Row(
                            children: [
                              Text(isIncrement
                                  ? 'Auto Increment'
                                  : 'Auto Decrement'),
                              Switch(
                                value: isIncrement,
                                onChanged: (value) {
                                  setState(() {
                                    isIncrement = value;
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    isChapterExists
                        ? TextButton(
                            onPressed: getChapterContent,
                            child: const Text('Get Content'),
                          )
                        : const SizedBox.shrink(),
                    //body
                    TTextField(
                      isSelectedAll: true,
                      controller: bodyTextController,
                      label: const Text('Chapter Body'),
                      maxLines: 15,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
