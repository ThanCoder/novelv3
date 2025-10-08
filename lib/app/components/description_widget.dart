import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DescriptionWidget extends StatelessWidget {
  final String text;
  final void Function(String url)? onClicked;
  const DescriptionWidget({super.key, required this.text, this.onClicked});

  @override
  Widget build(BuildContext context) {
    // return Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: SelectableText(text, style: TextStyle(fontSize: 16)),
    // );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text.rich(TextSpan(children: _buildSpans(text))),
    );
  }

  List<TextSpan> _buildSpans(String text) {
    final RegExp regex = RegExp(r'(https?:\/\/[^\s]+)');
    final List<TextSpan> spans = [];
    int start = 0;
    for (final match in regex.allMatches(text)) {
      // link မတိုင်ခင် အပိုင်း
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: const TextStyle(fontSize: 16),
          ),
        );
      }
      String url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(color: Colors.blue, fontSize: 16),
          mouseCursor: SystemMouseCursors.click,
          recognizer: TapGestureRecognizer()
            ..onTap = () => onClicked?.call(url),
        ),
      );

      start = match.end;
    }
    // ကျန်နေတဲ့ text
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return spans;
  }
}
