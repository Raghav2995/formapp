class FormModel {
  final int? id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String phone;
  final String address;

  FormModel({
    this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phone': phone,
      'address': address,
    };
  }

  factory FormModel.fromMap(Map<String, dynamic> map) {
    return FormModel(
      id: map['id'],
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      phone: map['phone'],
      address: map['address'],
    );
  }
}
