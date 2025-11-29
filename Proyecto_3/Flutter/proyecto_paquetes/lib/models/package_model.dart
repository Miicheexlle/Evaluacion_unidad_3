class PackageModel {
  final int packageId;
  final String clientName;
  final String address;
  final double? latitude;
  final double? longitude;

  PackageModel({
    required this.packageId,
    required this.clientName,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      packageId: json['package_id'] as int,
      clientName: json['client_name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}
