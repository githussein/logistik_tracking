import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String screenTitle;

  const CustomAppBar({
    required this.screenTitle,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const Image(image: AssetImage('assets/images/favicon.png')),
      backgroundColor: Colors.grey.shade800,
      title: Text(screenTitle, style: const TextStyle(color: Colors.white)),
    );
  }
}
