
class MenuItem {
  final int productPrivateId;
  final int productId;
  final String name;
  final String image;
  final int price;
  final String explanation;
  final Information information;

  MenuItem({
    required this.productPrivateId,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.explanation,
    required this.information,
  });

  // JSON 데이터를 Dart 객체로 변환하는 함수
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      productPrivateId: json['product_prvateid'],
      productId: json['product_id'],
      name: json['name'],
      image: json['image'],
      price: json['price'],
      explanation: json['explanation'],
      information: Information.fromJson(json['information']),
    );
  }
}

class Information {
  final int calories;
  final int saturatedFat;
  final int protein;
  final int sodium;
  final int sugar;
  final int caffeine;

  Information({
    required this.calories,
    required this.saturatedFat,
    required this.protein,
    required this.sodium,
    required this.sugar,
    required this.caffeine,
  });

  // JSON 데이터를 Dart 객체로 변환하는 함수
  factory Information.fromJson(Map<String, dynamic> json) {
    return Information(
      calories: json['calories'],
      saturatedFat: json['saturatedFat'],
      protein: json['protein'],
      sodium: json['sodium'],
      sugar: json['sugar'],
      caffeine: json['caffeine'],
    );
  }
}


