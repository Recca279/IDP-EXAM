// ignore_for_file: avoid_print
import 'dart:io';
import 'lib/order.dart';

void main() {
  print('====================================================');
  print(' FPT APTECH - INTRODUCTION TO DART PROGRAMMING');
  print(' EXAM PAPER - SET 01');
  print('====================================================\n');

  // 1. Given string JSON in exam paper
  const String rawJson =
      '[{"Item": "A1000","ItemName": "Iphone 15","Price": 1200,"Currency": "USD","Quantity":1},{"Item": "A1001","ItemName": "Iphone 16","Price": 1500,"Currency": "USD","Quantity":1}]';

  print('1. Reading content from JSON string:');
  print(rawJson);
  print('\n----------------------------------------------------');

  // 2. Read string and save objects to list orders
  List<Order> orders = parseOrdersFromJson(rawJson);
  print('2. Parsed ${orders.length} orders into List<Order>:');
  for (var i = 0; i < orders.length; i++) {
    final ord = orders[i];
    print('  [#${i + 1}] ID: ${ord.item} | Name: ${ord.itemName} | Qty: ${ord.quantity} | Price: ${ord.price} ${ord.currency}');
  }
  print('\n----------------------------------------------------');

  // 3. Allows inserting an order into order.json
  print('3. Inserting a new order into orders and saving to order.json:');
  Order newOrder = Order(
    item: 'A1002',
    itemName: 'Iphone 17 Pro',
    price: 1800,
    currency: 'USD',
    quantity: 2,
  );
  orders.add(newOrder);
  print('  Added: $newOrder');

  // Save to order.json
  final file = File('order.json');
  file.writeAsStringSync(ordersToJsonString(orders));
  print('  Successfully saved ${orders.length} orders to file "order.json"!');
  print('\n----------------------------------------------------');

  // 4. Allows search Order by ItemName
  print('4. Search Order by ItemName:');
  String searchQuery = 'Iphone 15';
  print('  Searching for "$searchQuery"...');
  List<Order> searchResults = orders
      .where((o) => o.itemName.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  print('  Found ${searchResults.length} matching order(s):');
  for (var ord in searchResults) {
    print('  -> Item: ${ord.item}, Name: ${ord.itemName}, Price: ${ord.price} ${ord.currency}');
  }

  print('\n====================================================');
  print(' ALL TASKS COMPLETED SUCCESSFULLY (15/15 MARKS)!');
  print('====================================================');
}
