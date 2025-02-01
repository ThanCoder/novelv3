import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/chapter_list_view.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';

class ChapterListDrawer extends StatefulWidget {
  const ChapterListDrawer({super.key});

  @override
  State<ChapterListDrawer> createState() => _ChapterListDrawerState();
}

class _ChapterListDrawerState extends State<ChapterListDrawer> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isLoading = false;

  void init() {
    try {
      if (currentNovelNotifier.value == null) return;
      setState(() {
        isLoading = true;
      });

      getChapterListFromPathIsolate(
        novelSourcePath: currentNovelNotifier.value!.path,
        onSuccess: (chapterList) {
          chapterListNotifier.value = chapterList;
          setState(() {
            isLoading = false;
          });
        },
        onError: (err) {
          setState(() {
            isLoading = false;
          });
          showMessage(context, err);
          debugPrint(err);
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      child: SizedBox(
        width: screenWidth < 400 ? screenWidth * 0.8 : screenWidth * 0.5,
        child: isLoading
            ? Center(
                child: TLoader(),
              )
            : ValueListenableBuilder(
                valueListenable: chapterListNotifier,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return const Center(
                      child: Text('chapter is empty!'),
                    );
                  }
                  return ChapterListView(
                    chapterList: value,
                    isSelected: true,
                    selectedTitle: currentChapterNotifier.value!.title,
                    onClick: (chapter) {
                      Navigator.pop(context);
                      currentChapterNotifier.value = chapter;
                    },
                  );
                },
              ),
      ),
    );
  }
}
