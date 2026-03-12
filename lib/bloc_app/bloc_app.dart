import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_type_tabbar_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/pdf_list_cubit.dart';
import 'package:novel_v3/bloc_app/routers.dart';
import 'package:novel_v3/core/services/chapter_services.dart';
import 'package:novel_v3/core/services/novel_bookmark_services.dart';
import 'package:novel_v3/core/services/novel_services.dart';
import 'package:novel_v3/core/services/pdf_services.dart';
import 'package:novel_v3/more_libs/setting/core/theme_listener.dart';

class BlocApp extends StatelessWidget {
  const BlocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => NovelServices()),
        RepositoryProvider(create: (context) => ChapterServices()),
        RepositoryProvider(create: (context) => NovelBookmarkServices()),
        RepositoryProvider(create: (context) => PdfServices()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                NovelListCubit(context.read<NovelServices>())..fetchNovel(),
          ),
          BlocProvider(
            create: (context) =>
                NovelDetailCubit(novelServices: context.read<NovelServices>()),
          ),
          BlocProvider(
            create: (context) => ChapterListCubit(
              context.read<ChapterServices>(),
              novelDetailCubit: context.read<NovelDetailCubit>(),
            ),
          ),
          BlocProvider(
            create: (context) => NovelTypeTabbarCubit(
              novelListCubit: context.read<NovelListCubit>(),
              novelBookmarkServices: context.read<NovelBookmarkServices>(),
            ),
          ),
          BlocProvider(
            create: (context) => PdfListCubit(
              context.read<PdfServices>(),
              novelDetailCubit: context.read<NovelDetailCubit>(),
            ),
          ),
        ],
        child: ThemeListener(
          builder: (context, themeMode) {
            return MaterialApp.router(
              routerConfig: routerConfig,
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              // home: HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}
