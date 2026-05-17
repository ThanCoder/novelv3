import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/main/styles/sliver_list_style.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class SearchResultScreen extends StatefulWidget {
  final String title;
  final List<Novel> list;
  final void Function(Novel novel) onClicked;
  const SearchResultScreen({
    super.key,
    required this.title,
    required this.list,
    required this.onClicked,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: CustomScrollView(slivers: [_getListWidget()]),
    );
  }

  Widget _getListWidget() {
    return SliverListStyle(
      list: widget.list,
      onClicked: widget.onClicked,
      onRightClicked: _onItemMenu,
    );
  }

  // item menu
  void _onItemMenu(Novel novel) {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit Novel'),
          onTap: () {
            context.close();
            goNovelEditScreen(context, novel: novel);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever),
          title: Text('Delete'),
          onTap: () {
            context.close();
            _deleteConfirm(novel);
          },
        ),
      ],
    );
  }

  void _deleteConfirm(Novel novel) {
    showTConfirmDialog(
      context,
      contentText: 'ဖျက်ချင်တာ သေချာပြီးလား?',
      submitText: 'Delete Forever',
      onSubmit: () {
        context.read<NovelListCubit>().delete(novel);
      },
    );
  }
}
