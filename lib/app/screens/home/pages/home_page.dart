import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/screens/home/novel_home_action_button.dart';
import 'package:novel_v3/app/screens/home/pages/novel_grid_style_page.dart';
import 'package:novel_v3/app/screens/home/pages/novel_home_list_page.dart';
import 'package:novel_v3/app/screens/home/pages/novel_list_style_page.dart';
import 'package:novel_v3/app/screens/home/search_button.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:novel_v3/app/setting/home_list_styles.dart';
import 'package:novel_v3/my_libs/general_server/general_server_noti_button.dart';
import 'package:than_pkg/extensions/platform_extension.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init({bool isReset = false}) async {
    await ref.read(novelNotifierProvider.notifier).initList(isReset: isReset);
  }

  AppBar get _getAppBar {
    return AppBar(
      title: const Text(appTitle),
      actions: [
        const GeneralServerNotiButton(),
        const SearchButton(),
        PlatformExtension.isDesktop()
            ? IconButton(
                onPressed: () {
                  init(isReset: true);
                },
                icon: const Icon(Icons.refresh),
              )
            : const SizedBox.shrink(),
        //menu
        const NovelHomeActionButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (appConfigNotifier.value.homeListStyle ==
        HomeListStyles.allNovelListStyle) {
      return NovelListStylePage(
        appBar: _getAppBar,
      );
    }
    if (appConfigNotifier.value.homeListStyle ==
        HomeListStyles.allNovelGridStyle) {
      return NovelGridStylePage(
        appBar: _getAppBar,
      );
    }
    return NovelHomeListPage(
      appBar: _getAppBar,
    );
  }
}
