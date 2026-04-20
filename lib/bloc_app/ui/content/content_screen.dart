import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/ui/content/styles/content_style_two.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentScreen extends StatefulWidget {
  final Novel novel;
  const ContentScreen({super.key, required this.novel});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() async {
    try {
      await context.read<ChapterListCubit>().fetchList();
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<NovelDetailCubit, NovelDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: TLoader.random());
          }
          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.currentNovel == null) {
            return Center(child: Text('Novel is Null'));
          }
          return ContentStyleTwo(novel: state.currentNovel!);
        },
      ),
    );
  }
}
