import 'dart:convert';

/// Class Order representing each ordered item in the exam
class Order {
  String item;
  String itemName;
  double price;
  String currency;
  int quantity;

  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  /// Factory constructor to create an Order instance from JSON Map
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      item: json['Item']?.toString() ?? '',
      itemName: json['ItemName']?.toString() ?? '',
      price: json['Price'] is num
          ? (json['Price'] as num).toDouble()
          : double.tryParse(json['Price']?.toString() ?? '0') ?? 0.0,
      currency: json['Currency']?.toString() ?? 'USD',
      quantity: json['Quantity'] is int
          ? json['Quantity'] as int
          : int.tryParse(json['Quantity']?.toString() ?? '1') ?? 1,
    );
  }

  /// Convert Order instance back to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'Item': item,
      'ItemName': itemName,
      'Price': price,
      'Currency': currency,
      'Quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'Order(Item: $item, ItemName: $itemName, Price: $price, Currency: $currency, Quantity: $quantity)';
  }
}

/// Helper function to parse JSON string into List<Order>
List<Order> parseOrdersFromJson(String jsonString) {
  final List<dynamic> parsedList = json.decode(jsonString);
  return parsedList.map((item) => Order.fromJson(item as Map<String, dynamic>)).toList();
}

/// Helper function to encode List<Order> to formatted JSON string
String ordersToJsonString(List<Order> orders) {
  final listMap = orders.map((o) => o.toJson()).toList();
  return const JsonEncoder.withIndent('  ').convert(listMap);
}
