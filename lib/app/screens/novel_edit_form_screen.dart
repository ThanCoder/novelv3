import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/index.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/services/core/app_services.dart';
import 'package:novel_v3/app/tag_components/tags_wrap_view.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_history_record.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_history_services.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_methods.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelEditFormScreen extends ConsumerStatefulWidget {
  NovelModel novel;
  NovelEditFormScreen({super.key, required this.novel});

  @override
  ConsumerState<NovelEditFormScreen> createState() =>
      _NovelEditFormScreenState();
}

class _NovelEditFormScreenState extends ConsumerState<NovelEditFormScreen> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final mcController = TextEditingController();
  final tagsController = TextEditingController();
  final contentController = TextEditingController();

  late NovelModel novel;
  bool isChanged = true;

  @override
  void initState() {
    novel = widget.novel;
    super.initState();
    init();
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    mcController.dispose();
    tagsController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void init() {
    titleController.text = novel.title;
    authorController.text = novel.author;
    mcController.text = novel.mc;
    contentController.text = novel.getContent;
  }

  void _saveNovel() async {
    try {
      if (novel.title != titleController.text) {
        //change dir
        novel = await novel.changeTitle(titleController.text);
      }
      novel.title = titleController.text;
      novel.author = authorController.text;
      novel.mc = mcController.text;
      novel.content = contentController.text;
      //save
      await novel.save();
      if (!mounted) return;
      ref.read(novelNotifierProvider.notifier).setCurrent(novel);

      Navigator.of(context).pop();
      THistoryServices.instance.add(THistoryRecord.create(
        title: novel.title,
        method: TMethods.update,
      ));
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form `${novel.title}`'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // cover
              Row(
                spacing: 5,
                children: [
                  Column(
                    children: [
                      const Text('Cover'),
                      CoverComponents(
                        coverPath: novel.coverPath,
                        onChanged: () {
                          if (!isChanged) {
                            setState(() {
                              isChanged = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Content Cover'),
                      CoverComponents(
                        coverPath: novel.contentCoverPath,
                        onChanged: () {
                          if (!isChanged) {
                            setState(() {
                              isChanged = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // form
              TTextField(
                controller: titleController,
                label: const Text('Title'),
                isSelectedAll: true,
                maxLines: 1,
                onChanged: (value) {
                  if (!isChanged) {
                    setState(() {
                      isChanged = true;
                    });
                  }
                },
              ),
              TTextField(
                controller: authorController,
                label: const Text('Author'),
                isSelectedAll: true,
                maxLines: 1,
                onChanged: (value) {
                  if (!isChanged) {
                    setState(() {
                      isChanged = true;
                    });
                  }
                },
              ),
              TTextField(
                controller: mcController,
                label: const Text('MC'),
                isSelectedAll: true,
                maxLines: 1,
                onChanged: (value) {
                  if (!isChanged) {
                    setState(() {
                      isChanged = true;
                    });
                  }
                },
              ),
              // status
              Row(
                spacing: 5,
                children: [
                  Row(
                    children: [
                      const Text('Adult'),
                      Switch(
                        value: novel.isAdult,
                        onChanged: (value) {
                          novel.isAdult = value;
                          if (!isChanged) {
                            isChanged = true;
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Completed'),
                      Switch(
                        value: novel.isCompleted,
                        onChanged: (value) {
                          novel.isCompleted = value;
                          if (!isChanged) {
                            isChanged = true;
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // page urls
              TagsWrapView(
                title: 'Page Links',
                values: novel.pageLink,
                onAddClicked: () {
                  showDialog(
                    context: context,
                    builder: (context) => RenameDialog(
                      title: 'Url ထည့်သွင်ခြင်း',
                      text: '',
                      onCheckIsError: (text) {
                        if (!text.startsWith('http')) {
                          return 'http နဲ့ စတာတွေပဲ လက်ခံပါတယ်';
                        }
                        final founds =
                            novel.getPageLinkList.where((n) => n == text);
                        if (founds.isNotEmpty) {
                          return 'url ရှိနေပြီးသား ဖြစ်နေပါတယ်...';
                        }
                        return null;
                      },
                      onCancel: () {},
                      onSubmit: (text) {
                        if (text.isEmpty) return;
                        final list = novel.getPageLinkList;
                        list.insert(0, text);
                        novel.setPageLinkList(list);
                        setState(() {
                          isChanged = true;
                        });
                      },
                    ),
                  );
                },
                onDeleted: (value) {
                  final res =
                      novel.getPageLinkList.where((n) => n != value).toList();
                  novel.setPageLinkList(res);
                  setState(() {
                    isChanged = true;
                  });
                },
                onClicked: (value) {
                  copyText(value);
                },
              ),
              //content
              TTextField(
                controller: contentController,
                label: const Text('Content'),
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
              onPressed: _saveNovel,
              child: const Icon(Icons.save_as_rounded),
            )
          : null,
    );
  }
}
