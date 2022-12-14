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
      backgroundColor: Colors.grey.shade800,
      title: Text(
          screenTitle,
          overflow: TextOverflow.fade,
          style: const TextStyle(color: Colors.white)),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }
}
