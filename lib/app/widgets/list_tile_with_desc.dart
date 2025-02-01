import 'package:flutter/material.dart';

class ListTileWithDesc extends StatelessWidget {
  String title;
  String? desc;
  Widget widget;
  ListTileWithDesc({
    super.key,
    required this.title,
    this.desc,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  desc != null ? const SizedBox(height: 5) : Container(),
                  desc != null
                      ? Text(
                          desc ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            widget,
          ],
        ),
      ),
    );
  }
}
