import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../providers/objects.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../models/object.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  static const routeName = '/objects';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isInit = true;
  var _isLoading = false;
  static const TextStyle _listHeaderStyle =
      TextStyle(fontWeight: FontWeight.w800, fontSize: 16);
  List<Object> orders = [];
  final _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() => _isLoading = true);
      Provider.of<Objects>(context)
          .fetchOrders(context)
          .then((_) =>
              orders = Provider.of<Objects>(context, listen: false).ordersList)
          .then((_) => setState(() => _isLoading = false));
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(screenTitle: AppLocalizations.of(context)!.orders),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      hintText: AppLocalizations.of(context)!.findOrders,
                      prefixIcon: const Icon(Icons.search, size: 30),
                      suffixIcon: _controller.text.isEmpty
                          ? IconButton(
                              icon: const Icon(Icons.qr_code, size: 30),
                              onPressed: () => scanQRCode(),
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 30),
                              onPressed: () {
                                _controller.clear();
                                searchOrder('');
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onChanged: searchOrder,
                  ),
                  ListTile(
                    dense: true,
                    selected: true,
                    leading: SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          AppLocalizations.of(context)!.orderId,
                          style: _listHeaderStyle,
                        )),
                    title: Text(
                      AppLocalizations.of(context)!.location,
                      style: _listHeaderStyle,
                    ),
                  ),
                  const Divider(thickness: 2),
                  Expanded(
                    child: Scrollbar(
                      child: ListView.separated(
                        separatorBuilder: (_, __) => const Divider(),
                        shrinkWrap: true,
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          String trackingId = orders[index].trackingId == ''
                              ? 'No tracking-id'
                              : orders[index].trackingId;

                          return ListTile(
                            onTap: () {},
                            dense: true,
                            leading: SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text(
                                trackingId,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: trackingId == 'No tracking-id'
                                        ? Colors.grey
                                        : Colors.black),
                              ),
                            ),
                            title: Text(
                              orders[index].location,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: orders[index].location == 'unknown'
                                      ? Colors.grey
                                      : Colors.black),
                            ),
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

  void searchOrder(String query) {
    orders = Provider.of<Objects>(context, listen: false).ordersList;

    final _filteredOrders = orders.where((order) {
      return order.trackingId
          .toString()
          .toLowerCase()
          .contains(query.toString().toLowerCase());
    }).toList();

    setState(() => orders = _filteredOrders);
  }

  Future<void> scanQRCode() async {
    try {
      String scannedCode = await FlutterBarcodeScanner.scanBarcode('#1aa7ec',
          AppLocalizations.of(context)!.cancel, true, ScanMode.BARCODE);

      if (!mounted) return;

      if (scannedCode == '-1') scannedCode = '';

      _controller.text = scannedCode;
      searchOrder(scannedCode);
    } on PlatformException {
      searchOrder('');
    }
  }
}
