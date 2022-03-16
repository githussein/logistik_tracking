class StepThresholds {
  final String location;
  final int warningDurationInSeconds;
  final int criticalDurationInSeconds;

  StepThresholds({
    required this.location,
    required this.warningDurationInSeconds,
    required this.criticalDurationInSeconds,
  });
}
