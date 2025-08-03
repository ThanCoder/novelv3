import 'package:flutter/material.dart';
import 'package:t_widgets/widgets/t_cache_image.dart';

import '../models/helper_file.dart';

class HelperContentScreen extends StatelessWidget {
  HelperFile helper;
  HelperContentScreen({super.key, required this.helper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(helper.title)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Text(helper.desc)),
          SliverToBoxAdapter(child: const Divider()),
          SliverList.builder(
            itemCount: helper.imagesUrl.length,
            itemBuilder: (context, index) {
              final url = helper.imagesUrl[index];
              return TCacheImage(url: url);
            },
          ),
        ],
      ),
    );
  }
}
