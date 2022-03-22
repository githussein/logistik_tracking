class Object {
  final int id;
  final String name;
  final String trackingId;
  String location;
  DateTime locationEnterTimestamp;
  bool materialA;
  bool materialB;

  Object({
    required this.id,
    required this.name,
    required this.trackingId,
    this.location = 'unknown',
    required this.locationEnterTimestamp,
    this.materialA = false,
    this.materialB = false,
  });
}
