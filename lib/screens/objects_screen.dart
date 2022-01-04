import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/objects.dart';
import '../widgets/custom_app_bar_widget.dart';

class ObjectsScreen extends StatefulWidget {
  const ObjectsScreen({Key? key}) : super(key: key);

  static const routeName = '/objects';

  @override
  State<ObjectsScreen> createState() => _ObjectsScreenState();
}

class _ObjectsScreenState extends State<ObjectsScreen> {
  var _isInit = true;
  var _isLoading = false;
  static const TextStyle _listHeaderStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() => _isLoading = true);
      Provider.of<Objects>(context)
          .fetchObjects(context)
          .then((_) => setState(() => _isLoading = false));
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final objects = Provider.of<Objects>(context, listen: false).objectsList;
    return Scaffold(
      appBar: const CustomAppBar(screenTitle: 'Objects'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const ListTile(
                    dense: true,
                    selected: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    leading: Text('ID', style: _listHeaderStyle),
                    title: Text('Name', style: _listHeaderStyle),
                  ),
                  const Divider(),
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: objects.length,
                        itemBuilder: (context, index) {
                          String objectName = objects[index].name == ''
                              ? 'dummy object'
                              : objects[index].name;
                          return ListTile(
                            onTap: () {},
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            dense: true,
                            leading: Text(objects[index].id.toString()),
                            title: Text(objectName,
                                style: const TextStyle(fontSize: 16)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
