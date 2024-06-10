final class Product {
  int? id;
  final String name;

  Product(this.id, this.name);

  @override
  int get hashCode {
    return name.hashCode;
  }

  @override
  String toString() {
    return "$id $name";
  }

  @override
  bool operator ==(Object other) {
    return other is Product && other.name == name;
  }
}
