import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_grid_item.dart';
import 'package:novel_v3/app/models/novel_model.dart';

class NovelSeeAllListView extends StatelessWidget {
  String title;
  List<NovelModel> list;
  int take;
  void Function() onSeeAllClicked;
  void Function(NovelModel novel) onClicked;
  NovelSeeAllListView({
    super.key,
    required this.title,
    required this.list,
    this.take = 5,
    required this.onClicked,
    required this.onSeeAllClicked,
  });

  Widget _getItem(NovelModel novel) {
    return SizedBox(
      width: 180,
      height: 200,
      child: NovelGridItem(
        novel: novel,
        onClick: onClicked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        //header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onSeeAllClicked,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
        ),
        //list
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.take(take).map((nv) => _getItem(nv)).toList(),
          ),
        ),
      ],
    );
  }
}
