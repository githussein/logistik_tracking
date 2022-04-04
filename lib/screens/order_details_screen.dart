import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/objects.dart';
import '../providers/thresholds.dart';
import '../models/object.dart';
import '../models/step_thresholds.dart';
import '../widgets/custom_app_bar_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen(this.object, {Key? key}) : super(key: key);

  final Object object;

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  TextStyle orderDetailsTextStyle = const TextStyle(fontSize: 24);
  final Color _okayColor = Colors.green.shade400.withOpacity(0.80);
  final Color _warningColor = Colors.orange.shade700.withOpacity(0.55);
  final Color _criticalColor = Colors.red.shade700.withOpacity(0.75);
  final Color _unknownColor = Colors.black54;
  late Color _statusColor;
  bool showWarningIcon = false;
  Duration duration = const Duration();
  Timer? timer;
  Object? viewedObject;
  late String trackingId;
  bool _isInit = true;
  bool _isLoading = false;

  void addTime() {
    const addSeconds = 1;

    if (mounted) {
      setState(() {
        final seconds = duration.inSeconds + addSeconds;
        duration = Duration(seconds: seconds);
      });
    }
  }

  void startTimer() =>
      timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    viewedObject = widget.object;
    trackingId = viewedObject!.trackingId == ''
        ? AppLocalizations.of(context)!.unknown
        : viewedObject!.trackingId;

    if (_isInit) {
      setState(() => _isLoading = true);
      Provider.of<ProcessStepThresholds>(context, listen: false)
          .fetchProcessModel(context)
          .then((value) async => viewedObject =
              await Provider.of<Objects>(context, listen: false)
                  .fetchObjectById(context, viewedObject!.id))
          .then((_) => setState(() => _isLoading = false));
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Widget buildTime(Duration timeDifference) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(timeDifference.inHours.remainder(24));
    final minutes = twoDigits(timeDifference.inMinutes.remainder(60));
    final seconds = twoDigits(timeDifference.inSeconds.remainder(60));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: MediaQuery.of(context).size.width / 7),
        const Icon(Icons.timer, color: Colors.white, size: 40),
        const SizedBox(width: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Text(
            '$hours:$minutes:$seconds',
            style: const TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<StepThresholds> thresholds =
        Provider.of<ProcessStepThresholds>(context, listen: false)
            .thresholdsList;

    Duration timeDifference =
        DateTime.now().difference(viewedObject!.locationEnterTimestamp);

    StepThresholds currentStep = thresholds.firstWhere(
        (threshold) => viewedObject!.location
            .toLowerCase()
            .contains(threshold.location.toLowerCase()),
        orElse: () => thresholds[0]);

    _statusColor = _okayColor;
    if (!timer!.isActive && _statusColor != Colors.black54) {
      startTimer();
    }

    if (currentStep.warningDurationInSeconds != -1 &&
        currentStep.criticalDurationInSeconds != -1 &&
        timeDifference.inSeconds >= currentStep.warningDurationInSeconds &&
        timeDifference.inSeconds < currentStep.criticalDurationInSeconds) {
      _statusColor = _warningColor;
    } else if (currentStep.warningDurationInSeconds != -1 &&
        currentStep.criticalDurationInSeconds == -1 &&
        timeDifference.inSeconds >= currentStep.warningDurationInSeconds) {
      _statusColor = _warningColor;
    } else if (timeDifference.inSeconds >=
            currentStep.criticalDurationInSeconds &&
        currentStep.criticalDurationInSeconds != -1) {
      _statusColor = _criticalColor;
    } else if (viewedObject!.location.toLowerCase().contains('unknown')) {
      _statusColor = _unknownColor;
      timer!.cancel();
    }

    showWarningIcon = _statusColor == _criticalColor ? true : false;

    Future<void> _refreshOrders() async {
      setState(() => _isLoading = true);
      Provider.of<ProcessStepThresholds>(context, listen: false)
          .fetchProcessModel(context)
          .then((value) async => viewedObject =
              await Provider.of<Objects>(context, listen: false)
                  .fetchObjectById(context, viewedObject!.id))
          .then((_) => setState(() => _isLoading = false));
    }

    return Scaffold(
      appBar: CustomAppBar(screenTitle: 'ID: $trackingId'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshOrders,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 50, left: 8, right: 20),
                      color: _statusColor,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.timeInProcessStep,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.start,
                              ),
                              if (showWarningIcon)
                                const Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 50,
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white, size: 40),
                              const SizedBox(width: 5),
                              Text(
                                viewedObject!.location
                                        .toLowerCase()
                                        .contains('unknown')
                                    ? AppLocalizations.of(context)!.unknown
                                    : viewedObject!.location,
                                style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          buildTime(timeDifference),
                        ],
                      ),
                    ),
                    viewedObject!.location.toLowerCase().contains('assembly')
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 20),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .materialAssembly,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Material A',
                                          style: orderDetailsTextStyle,
                                        ),
                                        const Spacer(flex: 3),
                                        Icon(
                                            viewedObject!.materialA
                                                    .toLowerCase()
                                                    .contains('assembled')
                                                ? Icons.check_circle_outline
                                                : Icons.radio_button_unchecked,
                                            color: viewedObject!.materialA
                                                    .toLowerCase()
                                                    .contains('assembled')
                                                ? Colors.green.shade300
                                                : Colors.grey,
                                            size: 32),
                                        const Spacer(flex: 2),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Text(
                                          'Material B',
                                          style: orderDetailsTextStyle,
                                        ),
                                        const Spacer(flex: 3),
                                        Icon(
                                            viewedObject!.materialB
                                                    .toLowerCase()
                                                    .contains('assembled')
                                                ? Icons.check_circle_outline
                                                : Icons.radio_button_unchecked,
                                            color: viewedObject!.materialB
                                                    .toLowerCase()
                                                    .contains('assembled')
                                                ? Colors.green.shade300
                                                : Colors.grey,
                                            size: 32),
                                        const Spacer(flex: 2),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : viewedObject!.location
                                .toLowerCase()
                                .contains('quality check')
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 20),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .shipmentStatus,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .readyForShipment,
                                              style: orderDetailsTextStyle,
                                            ),
                                            const Spacer(flex: 3),
                                            Icon(
                                                viewedObject!.readyForShipment
                                                        .toLowerCase()
                                                        .contains('yes')
                                                    ? Icons.check_circle_outline
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: viewedObject!
                                                        .readyForShipment
                                                        .toLowerCase()
                                                        .contains('yes')
                                                    ? Colors.green.shade300
                                                    : Colors.grey,
                                                size: 32),
                                            const Spacer(flex: 2),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                  ],
                ),
              ),
            ),
    );
  }
}
