import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_bookmark_list_cubit.dart';
import 'package:novel_v3/core/models/novel.dart';

class NovelBookmarkToggler extends StatelessWidget {
  final Novel novel;
  const NovelBookmarkToggler({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NovelBookmarkListCubit, NovelBookmarkListCubitState>(
      builder: (context, state) {
        final isExists = context.read<NovelBookmarkListCubit>().isExists(novel);
        return IconButton(
          onPressed: () {
            context.read<NovelBookmarkListCubit>().toggle(novel);
          },
          icon: isExists
              ? Icon(Icons.bookmark_remove, color: Colors.red)
              : Icon(Icons.bookmark_add, color: Colors.blue),
        );
      },
    );
  }
}
