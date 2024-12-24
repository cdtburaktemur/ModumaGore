import 'package:flutter/cupertino.dart';
import 'search_screen.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      child: const Icon(CupertinoIcons.search),
    );
  }
}
