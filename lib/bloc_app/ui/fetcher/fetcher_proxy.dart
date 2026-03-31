import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:t_widgets/t_widgets.dart';

class FetcherProxyIcon extends StatelessWidget {
  const FetcherProxyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showTMenuBottomSheetSingle(
          context,
          isDismissible: false,
          title: Text('Forward Proxy'),
          child: _FetcherProxyMenu(),
        );
      },
      icon: Icon(Icons.vpn_lock),
    );
  }
}

class _FetcherProxyMenu extends StatefulWidget {
  const _FetcherProxyMenu();

  @override
  State<_FetcherProxyMenu> createState() => _FetcherProxyMenuState();
}

class _FetcherProxyMenuState extends State<_FetcherProxyMenu> {
  final proxyUrlController = TextEditingController();

  @override
  void initState() {
    proxyUrlController.text = FetchServices.instance.getProxy();
    super.initState();
  }

  @override
  void dispose() {
    proxyUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: TScrollableColumn(
        children: [
          Text('နားမလည်ရင် မသုံးပါနဲ့'),

          TTextField(
            label: Text('Forward Proxy'),
            maxLines: 1,
            controller: proxyUrlController,
          ),
          TextButton(
            onPressed: () {
              proxyUrlController.text = '';
            },
            child: Text('Clear Proxy Url'),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  FetchServices.instance.setProxy(proxyUrlController.text);
                },
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
