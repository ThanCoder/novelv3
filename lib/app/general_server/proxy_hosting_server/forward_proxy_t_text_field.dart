import 'package:flutter/material.dart';

import '../../widgets/core/index.dart';
import '../index.dart';

class ForwardProxyTTextField extends StatefulWidget {
  TextEditingController controller;
  void Function(String value) onChanged;
  ForwardProxyTTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<ForwardProxyTTextField> createState() => _ForwardProxyTTextFieldState();
}

class _ForwardProxyTTextFieldState extends State<ForwardProxyTTextField> {
  void _onChooseOnline() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forward Proxy'),
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
                list = list.where((pro) => pro.type == 'forward').toList();
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
              return SizedBox.shrink();
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
            label: Text('Forward Proxy'),
            onChanged: widget.onChanged,
          ),
        ),
        IconButton(
          onPressed: _onChooseOnline,
          icon: Icon(Icons.cloud_download_rounded),
        ),
      ],
    );
  }
}
