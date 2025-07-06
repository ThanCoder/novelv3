import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/novel_list_item.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/extensions/novel_extension.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/home/novel_home_action_button.dart';
import 'package:novel_v3/app/screens/home/search_button.dart';
import 'package:novel_v3/my_libs/general_server/general_server_noti_button.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelListStylePage extends ConsumerStatefulWidget {
  const NovelListStylePage({super.key});

  @override
  ConsumerState<NovelListStylePage> createState() => _NovelListStylePageState();
}

class _NovelListStylePageState extends ConsumerState<NovelListStylePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init({bool isReset = false}) async {
    await ref.read(novelNotifierProvider.notifier).initList(isReset: isReset);
  }

  @override
  Widget build(BuildContext context) {
    final pro = ref.watch(novelNotifierProvider);
    final isLoading = pro.isLoading;
    final list = pro.list;
    // sort
    list.sortDate(false);

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: isLoading
          ? TLoader()
          : ListView.separated(
              itemBuilder: (context, index) => NovelListItem(
                novel: list[index],
                onClicked: (novel) => goNovelContentPage(context, ref, novel),
              ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: list.length,
            ),
    );
  }
}
