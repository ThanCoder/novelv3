import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/services/app_services.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';
import 'package:novel_v3/app/widgets/my_image_file.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';
import 'package:novel_v3/app/widgets/t_text_field.dart';
import 'package:provider/provider.dart';

import '../provider/index.dart';

class NovelFromScreen extends StatefulWidget {
  NovelModel novel;
  NovelFromScreen({super.key, required this.novel});

  @override
  State<NovelFromScreen> createState() => _NovelFromScreenState();
}

class _NovelFromScreenState extends State<NovelFromScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  List<NovelModel> allNovelList = [];
  late NovelModel novel;
  TextEditingController titleController = TextEditingController();
  TextEditingController pageUrlController = TextEditingController();
  TextEditingController mcController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  bool isChanged = false;
  bool isAdult = false;
  bool isCompleted = false;
  String? titleErrorText;

  void init() async {
    try {
      //set current
      novel = NovelModel.fromPath(widget.novel.path, isFullInfo: true);

      //get all novel list
      final novelList = await getNovelListFromPathIsolate();
      allNovelList = novelList;

      titleController.text = novel.title;
      pageUrlController.text = novel.pageLink;
      mcController.text = novel.mc;
      authorController.text = novel.author;
      contentController.text = novel.content;
      isAdult = novel.isAdult;
      isCompleted = novel.isCompleted;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveData() async {
    try {
      if (titleErrorText != null) {
        showMessage(context, 'title မှာ error ရှိနေပါတယ်!');
        return;
      }
      novel.title = titleController.text;
      novel.author = authorController.text;
      novel.content = contentController.text;
      novel.date = DateTime.now().millisecondsSinceEpoch;
      novel.isAdult = isAdult;
      novel.isCompleted = isCompleted;
      novel.mc = mcController.text;
      novel.pageLink = pageUrlController.text;

      await context
          .read<NovelProvider>()
          .update(novel: novel, oldTitle: widget.novel.title);

      //is success
      isChanged = false;
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void checkNovelTitle(String text) {
    try {
      final res = allNovelList.where((n) => n.title == text).toList();
      if (res.isEmpty) {
        setState(() {
          titleErrorText = null;
        });
      } else {
        setState(() {
          titleErrorText =
              'title ရှိနေပြီးသား ဖြစ်နေပါတယ်။အခြား title ကိုပြောင်းလဲပေးပါ!';
        });
      }
    } catch (e) {
      debugPrint('checkNovelTitle: ${e.toString()}');
    }
  }

  Future<bool> goBackConfirm() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('အတည်ပြုခြင်း'),
        content: const Text('ပြောင်းလဲထားတဲ့ data တွေကို သိမ်းဆည်းချင်ပါသလား?'),
        actions: [
          TextButton(
            onPressed: () {
              isChanged = false;
              Navigator.of(context).pop(true);
            },
            child: const Text('No'),
          ),
          IconButton(
            onPressed: () {
              saveData();
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.save_as),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isChanged) {
          return await goBackConfirm();
        } else {
          return true;
        }
      },
      child: MyScaffold(
        appBar: AppBar(
          title: Text(novel.title),
          actions: [
            //save
            IconButton(
              onPressed: () {
                saveData();
              },
              icon: const Icon(Icons.save_as),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //cover
                _NovelCover(novel: novel),
                const Divider(),
                TTextField(
                  label: const Text('Novel Title'),
                  controller: titleController,
                  errorText: titleErrorText,
                  onChanged: (value) {
                    isChanged = true;
                    if (value.isNotEmpty) {
                      checkNovelTitle(value);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TTextField(
                  label: const Text('Page Url'),
                  controller: pageUrlController,
                  onChanged: (value) {
                    isChanged = true;
                  },
                ),
                const SizedBox(height: 10),
                TTextField(
                  label: const Text('MC'),
                  controller: mcController,
                  onChanged: (value) {
                    isChanged = true;
                  },
                ),
                const SizedBox(height: 10),
                TTextField(
                  label: const Text('Author'),
                  controller: authorController,
                  onChanged: (value) {
                    isChanged = true;
                  },
                ),
                const SizedBox(height: 10),
                //switch
                Row(
                  children: [
                    //is Adult
                    Row(
                      children: [
                        const Text('Adult'),
                        Switch(
                          value: isAdult,
                          onChanged: (value) {
                            isChanged = true;
                            setState(() {
                              isAdult = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    //is Completed
                    Row(
                      children: [
                        const Text('Completed'),
                        Switch(
                          value: isCompleted,
                          onChanged: (value) {
                            isChanged = true;
                            setState(() {
                              isCompleted = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                //content
                const SizedBox(height: 10),
                TTextField(
                  label: const Text('Content or Review'),
                  controller: contentController,
                  maxLines: 7,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//novel cover
class _NovelCover extends StatefulWidget {
  NovelModel novel;
  _NovelCover({super.key, required this.novel});

  @override
  State<_NovelCover> createState() => _NovelCoverState();
}

class _NovelCoverState extends State<_NovelCover> {
  bool isContentCoverMenu = false;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  //change cover
  void changeCover() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await _picker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        final file = File(res.path);
        if (isContentCoverMenu) {
          await file.copy(widget.novel.contentCoverPath);
        } else {
          await file.copy(widget.novel.coverPath);
        }
      }
      await clearAndRefreshImage();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('changeCover: ${e.toString()}');
    }
  }

  void deleteCover() async {
    if (isContentCoverMenu) {
      final file = File(widget.novel.contentCoverPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } else {
      final file = File(widget.novel.coverPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    // await clearAndRefreshImage();
    setState(() {});
  }

  void showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          //change cover
          ListTile(
            onTap: () {
              Navigator.pop(context);
              changeCover();
            },
            leading: const Icon(Icons.change_circle),
            title: Text(
                'Change ${isContentCoverMenu ? 'Content Cover' : 'Cover'}'),
          ),
          //delete
          ListTile(
            onTap: () {
              Navigator.pop(context);
              deleteCover();
            },
            leading: const Icon(Icons.delete_forever),
            title: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: TLoader(),
      );
    }
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            isContentCoverMenu = false;
            showMenu();
          },
          child: Column(
            children: [
              const Text('Novel Cover'),
              SizedBox(
                width: 130,
                height: 140,
                child: MyImageFile(path: widget.novel.coverPath),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () {
            isContentCoverMenu = true;
            showMenu();
          },
          child: Column(
            children: [
              const Text('Content Cover'),
              SizedBox(
                width: 130,
                height: 140,
                child: MyImageFile(path: widget.novel.contentCoverPath),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
