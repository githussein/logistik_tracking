import 'package:flutter/material.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../models/features_list.dart';
import '../widgets/feature_item_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(screenTitle: 'Features'),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 8),
            children: featuresList
                .map((feature) =>
                    FeatureItem(title: feature.title, icon: feature.icon))
                .toList()),
      ),
    );
  }
}
