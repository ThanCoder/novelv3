import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/core/app_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_text_field.dart';
import 'package:provider/provider.dart';

import '../../provider/index.dart';

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
      chapterNumber = context.read<ChapterProvider>().lastChapter + 1;
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
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Add New Chapter'),
        actions: [
          IconButton(
            onPressed: addChapter,
            icon: const Icon(Icons.add_circle_rounded),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TTextField(
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
                const SizedBox(height: 10),
                //header
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          bodyTextController.text = await pasteFromClipboard();
                        },
                        icon: const Icon(Icons.paste),
                      ),
                      const SizedBox(width: 10),
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
                const SizedBox(height: 10),
                isChapterExists
                    ? TextButton(
                        onPressed: getChapterContent,
                        child: const Text('Get Content'),
                      )
                    : Container(),
                isChapterExists ? const SizedBox(height: 10) : Container(),
                //body
                TTextField(
                  controller: bodyTextController,
                  label: const Text('Chapter Body'),
                  maxLines: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
