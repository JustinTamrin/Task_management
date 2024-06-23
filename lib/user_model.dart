class UserModel {
  final String username;
  final String email;

  const UserModel({
    required this.username,
    required this.email,
  });

  toJson() {
    return {
      "Username": username,
      "Email": email,
    };
  }
}
