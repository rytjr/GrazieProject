class MenuItem {
  final String imageUrl;
  final String name;
  final String price;

  MenuItem({required this.imageUrl, required this.name, required this.price});

  // JSON 데이터를 MenuItem 객체로 변환
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      imageUrl: json['imageUrl'],
      name: json['name'],
      price: json['price'],
    );
  }
}