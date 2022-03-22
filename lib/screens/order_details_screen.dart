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
  Color statusColor = Colors.green.shade400.withOpacity(0.70);
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
        (threshold) => threshold.location == viewedObject!.location,
        orElse: () => thresholds[0]);
    if (viewedObject!.location == 'unknown') {
      timer!.cancel();
      statusColor = Colors.black45;
    } else if (timeDifference.inSeconds <
            currentStep.warningDurationInSeconds &&
        timeDifference.inSeconds < currentStep.criticalDurationInSeconds) {
      statusColor = Colors.green.shade400.withOpacity(0.70);
    } else if (timeDifference.inSeconds >=
            currentStep.warningDurationInSeconds &&
        timeDifference.inSeconds < currentStep.criticalDurationInSeconds) {
      statusColor = Colors.orange.shade700.withOpacity(0.55);
    } else if (timeDifference.inSeconds >=
        currentStep.criticalDurationInSeconds) {
      statusColor = Colors.red.shade700.withOpacity(0.75);
      showWarningIcon = true;
    }

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
                      color: statusColor,
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
                                viewedObject!.location == 'unknown'
                                    ? AppLocalizations.of(context)!.unknown
                                    : viewedObject!.location,
                                style: const TextStyle(
                                    fontSize: 40,
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
                    viewedObject!.location.toLowerCase() == 'assembly'
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
                                                ? Icons.check_circle_outline
                                                : Icons.radio_button_unchecked,
                                            color: Colors.green.shade300,
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
                                                ? Icons.check_circle_outline
                                                : Icons.radio_button_unchecked,
                                            color: Colors.black54,
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
