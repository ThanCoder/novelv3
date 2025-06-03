import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../app/dialogs/core/index.dart';
import '../../app/services/core/index.dart';
import '../../app/components/index.dart';

class CacheComponent extends StatefulWidget {
  const CacheComponent({super.key});

  @override
  State<CacheComponent> createState() => _CacheComponentState();
}

class _CacheComponentState extends State<CacheComponent> {
  @override
  Widget build(BuildContext context) {
    if (CacheServices.getCount() == 0) {
      return const SizedBox.shrink();
    }
    return TListTileWithDesc(
      onClick: () {
        showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            title: 'Clean Cache',
            contentText:
                'Count:${CacheServices.getCount()} \nSize:${CacheServices.getSize().toDouble().toFileSizeLabel()}',
            submitText: 'Clean',
            onCancel: () {},
            onSubmit: () async {
              showMessage(context, 'Cache Cleanning...');
              await CacheServices.clean();
              setState(() {});
            },
          ),
        );
      },
      leading: const Icon(Icons.delete_forever),
      title: 'Clean Cache',
      desc:
          'Cache: Count:${CacheServices.getCount()} - Size:${CacheServices.getSize().toDouble().toFileSizeLabel()}',
    );
  }
}
