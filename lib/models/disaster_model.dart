class DisasterModel {
  final String title;
  final String description;
  final String advice;
  final double? lat;
  final double? lng;

  DisasterModel({
    required this.title,
    required this.description,
    required this.advice,
    this.lat,
    this.lng,
  });
}
