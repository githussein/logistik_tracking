class Object {
  final int id;
  final String name;
  final String trackingId;
  String location;
  DateTime locationEnterTimestamp;
  String materialA;
  String materialB;
  String readyForShipment;

  Object({
    required this.id,
    required this.name,
    required this.trackingId,
    this.location = 'unknown',
    required this.locationEnterTimestamp,
    this.materialA = 'missing',
    this.materialB = 'missing',
    this.readyForShipment = 'no',
  });
}
