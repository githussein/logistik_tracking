class Object {
  final int id;
  final String name;
  final String trackingId;
  final String location;
  final DateTime locationEnterTimestamp;
  bool materialA = false;
  bool materialB = false;

  Object({
    required this.id,
    required this.name,
    required this.trackingId,
    required this.location,
    required this.locationEnterTimestamp,
    required this.materialA,
    required this.materialB,
  });
}
