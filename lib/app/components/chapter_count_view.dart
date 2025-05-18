import 'package:flutter/material.dart';
import 'package:novel_v3/app/services/chapter_services.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterCountView extends StatelessWidget {
  String title;
  TextStyle? style;
  String novelPath;
  ChapterCountView({
    super.key,
    required this.novelPath,
    this.title = 'Count: ',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ChapterServices.instance.getList(novelPath: novelPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 25,
            height: 25,
            child: TLoader(size: 25),
          );
        }
        if (snapshot.hasData) {
          final list = snapshot.data ?? [];
          if (list.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(228, 22, 22, 22),
            ),
            child: Text(
              '$title${list.length}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
