import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/screens/home/pages/novel_home_list_page.dart';
import 'package:novel_v3/app/screens/home/pages/novel_list_style_page.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:novel_v3/app/setting/home_list_styles.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    if (appConfigNotifier.value.homeListStyle ==
        HomeListStyles.allNovelListStyle) {
      return const NovelListStylePage();
    }
    return const NovelHomeListPage();
  }
}
