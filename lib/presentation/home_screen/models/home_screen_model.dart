class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;

  UserModel({required this.uid, required this.name, required this.email, this.photoUrl = ''});

  // Create a copy with modified values
  UserModel copyWith({String? name, String? email, String? photoUrl}) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
