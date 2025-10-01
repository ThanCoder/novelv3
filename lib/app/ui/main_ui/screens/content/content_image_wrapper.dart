import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentImageWrapper extends StatefulWidget {
  List<Widget> Function(BuildContext context, Novel novel) sliverBuilder;
  Widget? title;
  bool automaticallyImplyLeading;
  Future<void> Function()? onRefresh;
  bool isLoading;
  List<Widget> appBarAction;
  ContentImageWrapper({
    super.key,
    required this.sliverBuilder,
    this.title,
    this.automaticallyImplyLeading = true,
    this.onRefresh,
    this.isLoading = false,
    this.appBarAction = const [],
  });

  @override
  State<ContentImageWrapper> createState() => _ContentImageWrapperState();
}

class _ContentImageWrapperState extends State<ContentImageWrapper> {
  @override
  Widget build(BuildContext context) {
    final novel = context.watch<NovelProvider>().getCurrent;
    if (novel == null) {
      return Scaffold(appBar: AppBar(title: Text('Novel is null!')));
    }
    return ValueListenableBuilder(
      valueListenable: Setting.getAppConfigNotifier,
      builder: (context, value, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: Setting.getAppConfigNotifier,
                builder: (context, config, child) {
                  if (config.customNovelContentImagePath.isNotEmpty &&
                      File(config.customNovelContentImagePath).existsSync()) {
                    return TImage(source: config.customNovelContentImagePath);
                  }
                  return TImage(
                    source: novel.getCoverPath,
                    defaultAssetsPath: 'assets/logo_2.jpg',
                  );
                },
              ),
            ),
            Container(
              color: Setting.getAppConfig.isDarkMode
                  ? Colors.black.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
            ),
            widget.isLoading
                ? Center(child: TLoaderRandom())
                : _getRefershSwitcher(),
          ],
        );
      },
    );
  }

  Widget _getSliver() {
    final novel = context.watch<NovelProvider>().getCurrent;
    return CustomScrollView(
      slivers: [
        // appbar
        SliverAppBar(
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          title: widget.title,
          floating: true,
          snap: true,

          backgroundColor: Setting.getAppConfig.isDarkMode
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.3),
          actions: widget.appBarAction,
        ),
        // sliver builder
        ...widget.sliverBuilder(context, novel!),
      ],
    );
  }

  Widget _getRefershSwitcher() {
    if (widget.onRefresh != null) {
      return RefreshIndicator.adaptive(
        onRefresh: widget.onRefresh!,
        child: _getSliver(),
      );
    }
    return _getSliver();
  }
}
