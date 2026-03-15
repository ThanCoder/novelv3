import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/components/circle_button.dart';
import 'package:novel_v3/bloc_app/ui/content/styles/content_style_two.dart';
import 'package:novel_v3/bloc_app/ui/forms/add_chapter_form.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/utils.dart';
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
      appBar: AppBar(actions: _actions()),
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

  List<Widget> _actions() {
    return [
      CircleButton(
        icon: Icon(Icons.more_vert, color: Colors.white),
        onTap: _showMainMenu,
      ),
    ];
  }

  // show menu
  void _showMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter'),
          onTap: () {
            context.closeNavigator();
            goBlocRoute(
              context,
              builder: (context) => AddChapterForm(novel: widget.novel),
            );
          },
        ),
      ],
    );
  }
}
