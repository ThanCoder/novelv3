import 'package:flutter/material.dart';

class SeeAllView<T> extends StatelessWidget {
  List<T> list;
  String title;
  String moreTitle;
  int showCount;
  int? showLines;
  double fontSize;
  double padding;
  EdgeInsetsGeometry? margin;
  Color? titleColor;
  void Function(String title, List<T> list) onSeeAllClicked;
  Widget Function(BuildContext context, T item) gridItemBuilder;

  SeeAllView({
    super.key,
    required this.title,
    required this.list,
    required this.onSeeAllClicked,
    required this.gridItemBuilder,
    this.showCount = 8,
    this.margin,
    this.showLines,
    this.fontSize = 11,
    this.padding = 6,
    this.moreTitle = 'More',
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final showList = list.take(showCount).toList();
    if (showList.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        // header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: titleColor)),
            list.length > showCount
                ? Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: TextButton(
                      onPressed: () => onSeeAllClicked(title, list),
                      child: Text(
                        moreTitle,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        // grid item
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 5,
            children: List.generate(
              showList.length,
              (index) => gridItemBuilder(context, showList[index]),
            ),
          ),
        ),
      ],
    );

    // old methods
    // return Container(
    //   padding: EdgeInsets.all(padding),
    //   margin: margin,
    //   child: SizedBox(
    //     height: showLine * 170,
    //     child: Column(
    //       spacing: 5,
    //       children: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(title, style: TextStyle(color: titleColor)),
    //             list.length > showCount
    //                 ? Container(
    //                     margin: const EdgeInsets.only(right: 5),
    //                     child: TextButton(
    //                       onPressed: () => onSeeAllClicked(title, list),
    //                       child: Text(
    //                         moreTitle,
    //                         style: const TextStyle(color: Colors.blue),
    //                       ),
    //                     ),
    //                   )
    //                 : const SizedBox.shrink(),
    //           ],
    //         ),
    //         Expanded(
    //           child: GridView.builder(
    //             scrollDirection: Axis.horizontal,
    //             itemCount: showList.length,
    //             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    //               maxCrossAxisExtent: 170,
    //               mainAxisExtent: 130,
    //               mainAxisSpacing: 5,
    //               crossAxisSpacing: 5,
    //             ),
    //             itemBuilder: itemBuilder,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
