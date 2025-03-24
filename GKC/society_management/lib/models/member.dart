class Member {
  final String id;
  final String name;
  final String contactNumber;
  final String email;
  final String houseNumber;
  final bool isOwner;
  final bool hasPaid;
  final double latitude;
  final double longitude;

  Member({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.houseNumber,
    required this.isOwner,
    required this.hasPaid,
    required this.latitude,
    required this.longitude,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      houseNumber: json['houseNumber'],
      isOwner: json['isOwner'],
      hasPaid: json['hasPaid'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactNumber': contactNumber,
      'email': email,
      'houseNumber': houseNumber,
      'isOwner': isOwner,
      'hasPaid': hasPaid,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
} 