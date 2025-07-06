import 'package:flutter/material.dart';

import 'package:novel_v3/app/screens/search/search_screen.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      icon: const Icon(Icons.search),
    );
  }
}
