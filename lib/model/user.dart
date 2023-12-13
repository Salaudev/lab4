class User {
  late int? id; // Making the id nullable

  late String name;
  late String email;

  User({this.id, required this.name, required this.email});

  User.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    email = map['email'];
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email};
  }
}
