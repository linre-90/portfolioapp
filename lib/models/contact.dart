/// Model for contact.
class Contact {
  int id;
  String name;
  String headline;
  String message;
  String date;
  String email;
  bool read;

  Contact(this.id, this.name, this.headline, this.message, this.date,
      this.email, this.read);

  /// Convert json object to Contact
  static Contact fromJson(e) {
    return Contact(
        e["id"],
        e["name"].toString(),
        e["headline"].toString(),
        e["message"].toString(),
        e["date"].toString(),
        e["email"].toString(),
        e["read"]);
  }
}
