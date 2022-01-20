import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/objects_screen.dart';

class FeatureItem extends StatelessWidget {
  const FeatureItem({Key? key, required this.title, required this.icon})
      : super(key: key);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade300,
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        splashColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          switch (title) {
            case 'Objects':
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ObjectsScreen()));
              break;
            case 'Labels':
              break;
            default:
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Center(
                child: FaIcon(
                  icon,
                  size: 80,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            Container(
              color: Theme.of(context).primaryColorDark,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
