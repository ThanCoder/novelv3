import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_bookmark_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_bookmark_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_type_tabbar_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/pdf_list_cubit.dart';
import 'package:novel_v3/bloc_app/ui/main/bloc_home_screen.dart';
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
            create: (context) => NovelDetailCubit(
              novelServices: context.read<NovelServices>(),
              novelListCubit: context.read<NovelListCubit>(),
            ),
          ),
          BlocProvider(
            create: (context) => ChapterListCubit(
              novelDetailCubit: context.read<NovelDetailCubit>(),
            ),
          ),

          BlocProvider(
            create: (context) => PdfListCubit(
              context.read<PdfServices>(),
              novelDetailCubit: context.read<NovelDetailCubit>(),
            ),
          ),
          BlocProvider(
            create: (context) => ChapterBookmarkListCubit(
              novelDetailCubit: context.read<NovelDetailCubit>(),
            ),
          ),
          BlocProvider(create: (context) => NovelBookmarkListCubit()..fetch()),
          BlocProvider(
            create: (context) => NovelTypeTabbarCubit(
              novelListCubit: context.read<NovelListCubit>(),
              novelBookmarkListCubit: context.read<NovelBookmarkListCubit>(),
            ),
          ),
        ],
        child: ThemeListener(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              home: BlocHomeScreen(),
            );
          },
        ),
      ),
    );
  }
}
