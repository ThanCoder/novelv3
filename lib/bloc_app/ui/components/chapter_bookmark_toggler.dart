import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_bookmark_list_cubit.dart';
import 'package:novel_v3/core/models/chapter_bookmark.dart';

class ChapterBookmarkToggler extends StatelessWidget {
  final ChapterBookmark bookmark;
  const ChapterBookmarkToggler({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterBookmarkListCubit, ChapterBookmarkListCubitState>(
      builder: (context, state) {
        final index = state.list.indexWhere(
          (e) => e.chapter == bookmark.chapter,
        );
        final isExists = index != -1;
        return IconButton(
          onPressed: () {
            context.read<ChapterBookmarkListCubit>().toggle(bookmark);
          },
          icon: isExists
              ? Icon(Icons.bookmark_remove, color: Colors.red)
              : Icon(Icons.bookmark_add, color: Colors.blue),
        );
      },
    );
  }
}
