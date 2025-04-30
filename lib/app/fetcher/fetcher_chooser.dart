import 'package:flutter/material.dart';
import 'package:novel_v3/app/fetcher/fetcher_config_services.dart';
import 'package:novel_v3/app/fetcher/types/fetcher.dart';

class FetcherChooser extends StatefulWidget {
  Fetcher? fetcher;
  void Function(Fetcher fetcher) onChoosed;
  FetcherChooser({
    super.key,
    this.fetcher,
    required this.onChoosed,
  });

  @override
  State<FetcherChooser> createState() => _FetcherChooserState();
}

class _FetcherChooserState extends State<FetcherChooser> {
  @override
  void initState() {
    if (widget.fetcher != null) {
      current = widget.fetcher;
    }
    super.initState();
    init();
  }

  List<Fetcher> list = [];
  Fetcher? current;

  void init() async {
    list = await FetcherConfigServices.getList();
    if (list.isNotEmpty) {
      current = list.first;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Fetcher>(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(3),
      value: current,
      items: list
          .map(
            (fc) => DropdownMenuItem<Fetcher>(
              value: fc,
              child: Text(fc.title),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        current = value;
        setState(() {});
        widget.onChoosed(value);
      },
    );
  }
}
