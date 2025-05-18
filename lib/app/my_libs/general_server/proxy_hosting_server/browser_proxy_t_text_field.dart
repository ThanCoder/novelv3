import 'package:t_widgets/t_widgets.dart';

import '../index.dart';
import 'package:flutter/material.dart';

class BrowserProxyTTextField extends StatefulWidget {
  TextEditingController controller;
  void Function(String value) onChanged;
  BrowserProxyTTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<BrowserProxyTTextField> createState() => _BrowserProxyTTextFieldState();
}

class _BrowserProxyTTextFieldState extends State<BrowserProxyTTextField> {
  void _onChooseOnline() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Browser Proxy'),
        content: SingleChildScrollView(
          child: FutureBuilder(
            future: GeneralServices.instance.getProxyList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return TLoader();
              }
              if (snapshot.hasData) {
                var list = snapshot.data ?? [];
                //filter
                list = list.where((pro) => pro.type == 'browser').toList();
                return Column(
                  spacing: 5,
                  children: List.generate(
                    list.length,
                    (index) {
                      final proxy = list[index];
                      return ListTile(
                        textColor: proxy.url == widget.controller.text
                            ? Colors.teal
                            : null,
                        onTap: () {
                          widget.controller.text = proxy.url;
                          widget.onChanged(proxy.url);
                          Navigator.pop(context);
                        },
                        leading: Text(proxy.type),
                        title: Text(proxy.url),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Expanded(
          child: TTextField(
            controller: widget.controller,
            label: const Text('Browser Proxy'),
            onChanged: widget.onChanged,
          ),
        ),
        IconButton(
          onPressed: _onChooseOnline,
          icon: const Icon(Icons.cloud_download_rounded),
        ),
      ],
    );
  }
}
