import 'package:flutter/material.dart';

class SeeAllScreen<T> extends StatelessWidget {
  Widget title;
  List<T> list;
  Widget? Function(BuildContext context, T item) gridItemBuilder;
  SeeAllScreen({
    super.key,
    required this.title,
    required this.list,
    required this.gridItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: list.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisExtent: 200,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemBuilder: (context, index) => gridItemBuilder(context, list[index]),
        ),
      ),
    );
  }
}
