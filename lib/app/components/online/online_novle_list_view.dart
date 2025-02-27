import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/widgets/index.dart';

class OnlineNovleListView extends StatelessWidget {
  List<OnlineNovelModel> novelList;
  void Function(OnlineNovelModel novel) onClick;
  OnlineNovleListView({
    super.key,
    required this.novelList,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: novelList.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 200,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final novel = novelList[index];
        return GestureDetector(
          onTap: () => onClick(novel),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: MyImageUrl(
                        url: novel.coverUrl,
                        borderRadius: 5,
                      ),
                    ),
                  ],
                ),

                //title
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(108, 0, 0, 0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        novel.title,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
