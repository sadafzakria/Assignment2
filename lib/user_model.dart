class User {
  int? id;
  String? name;
  String? contactPhone;
  String? ssn;
  String? address;

  User({this.id, this.name, this.contactPhone, this.ssn, this.address});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactPhone': contactPhone,
      'ssn': ssn,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      contactPhone: map['contactPhone'],
      ssn: map['ssn'],
      address: map['address'],
    );
  }
}
