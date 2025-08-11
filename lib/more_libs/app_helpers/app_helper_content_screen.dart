import 'package:flutter/material.dart';

import 'app_helper.dart';

class AppHelperContentScreen extends StatelessWidget {
  AppHelper helper;
  AppHelperContentScreen({super.key, required this.helper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Text(helper.title,textAlign: TextAlign.center,maxLines: null,),
          ),
          SliverToBoxAdapter(
            child: Text(helper.desc,maxLines: null,),
          ),
          SliverList.builder(
              itemCount: helper.images.length,
              itemBuilder: (context, index) {
                final item = helper.images[index];
                return SizedBox(
                  width: 200,
                  child: Image.asset(
                    item,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) => Text('error'),
                    
                  ),
                );
              })
        ],
      ),
    );
  }
}
