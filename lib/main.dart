import 'package:flutter/material.dart';
import 'order.dart';

void main() {
  runApp(const MyOrderApp());
}

class MyOrderApp extends StatelessWidget {
  const MyOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Order - Introduction to Dart Programming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC85A32)),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'sans-serif',
      ),
      home: const OrderManagementScreen(),
    );
  }
}

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  // Initial JSON string given in exam paper
  static const String initialJsonString =
      '[{"Item": "A1000","ItemName": "Iphone 15","Price": 1200,"Currency": "USD","Quantity":1},{"Item": "A1001","ItemName": "Iphone 16","Price": 1500,"Currency": "USD","Quantity":1}]';

  // State
  late List<Order> _orders;
  String _searchQuery = '';

  // Controllers
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController(text: 'USD');
  final TextEditingController _searchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Primary Theme Colors (Coral / Terracotta from Exam Paper)
  final Color primaryColor = const Color(0xFFC85A32);
  final Color titleColor = const Color(0xFFE5A638); // Golden yellow for "My Order"

  @override
  void initState() {
    super.initState();
    _loadInitialOrders();
  }

  void _loadInitialOrders() {
    try {
      _orders = parseOrdersFromJson(initialJsonString);
    } catch (e) {
      _orders = [];
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _itemNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _currencyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Insert Order
  void _addOrder() {
    final item = _itemController.text.trim();
    final itemName = _itemNameController.text.trim();
    final priceText = _priceController.text.trim();
    final quantityText = _quantityController.text.trim();
    final currency = _currencyController.text.trim().isEmpty
        ? 'USD'
        : _currencyController.text.trim();

    if (item.isEmpty || itemName.isEmpty || priceText.isEmpty || quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ các trường thông tin!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final price = double.tryParse(priceText) ?? 0.0;
    final quantity = int.tryParse(quantityText) ?? 1;

    final newOrder = Order(
      item: item,
      itemName: itemName,
      price: price,
      currency: currency,
      quantity: quantity,
    );

    setState(() {
      _orders.add(newOrder);
      // Clear input fields
      _itemController.clear();
      _itemNameController.clear();
      _priceController.clear();
      _quantityController.clear();
      _currencyController.text = 'USD';
    });

    // Notify user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm sản phẩm "${newOrder.itemName}" vào order.json thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Delete Order
  void _deleteOrder(int index) {
    final deleted = _orders[index];
    setState(() {
      _orders.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa đơn hàng ${deleted.item}'),
        backgroundColor: Colors.grey.shade700,
      ),
    );
  }

  // Format Price with dot (e.g., 1.200)
  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      final intVal = price.toInt();
      // Format with dot separator like in the exam image "1.200"
      final str = intVal.toString();
      final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
      return str.replaceAll(reg, '.');
    }
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    // Filtered orders by ItemName
    final filteredOrders = _orders.where((order) {
      if (_searchQuery.isEmpty) return true;
      return order.itemName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Page Title "My Order"
                        Center(
                          child: Text(
                            'My Order',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Inputs
                        _buildInputForm(),
                        const SizedBox(height: 12),

                        // Add Item to Cart Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _addOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add Item to Cart',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Search Bar (Allows search Order by ItemName)
                        _buildSearchBar(),
                        const SizedBox(height: 16),

                        // Orders Table
                        _buildOrdersTable(filteredOrders),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer Bar
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Row 1: Item & Item Name
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'Item',
                  placeholder: 'Item',
                  controller: _itemController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildLabeledField(
                  label: 'Item Name',
                  placeholder: 'Item Name',
                  controller: _itemNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Price, Quantity, Currency
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildLabeledField(
                  label: 'Price',
                  placeholder: 'Price',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildLabeledField(
                  label: 'Quantity',
                  placeholder: 'Quantity',
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildLabeledField(
                  label: 'Currency',
                  placeholder: 'USD',
                  controller: _currencyController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 42,
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search Order by ItemName (e.g. Iphone 15)...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              splashRadius: 16,
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(List<Order> displayList) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            color: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Text('Id', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Item', style: _headerStyle)),
                Expanded(flex: 3, child: Text('Item Name', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Quantity', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Price', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Currency', style: _headerStyle)),
                SizedBox(width: 40, child: Center(child: Text('', style: _headerStyle))),
              ],
            ),
          ),

          // Table Rows
          if (displayList.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Không tìm thấy đơn hàng nào khớp với "$_searchQuery"!'
                    : 'Chưa có đơn hàng nào!',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final order = displayList[index];
                final originalIndex = _orders.indexOf(order);

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Id: 1, 2, 3...
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      // Item (A1000...)
                      Expanded(
                        flex: 2,
                        child: Text(
                          order.item,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      // Item Name (Iphone 15...)
                      Expanded(
                        flex: 3,
                        child: Text(
                          order.itemName,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      // Quantity
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${order.quantity}',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      // Price (1.200...)
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatPrice(order.price),
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      // Currency (USD)
                      Expanded(
                        flex: 2,
                        child: Text(
                          order.currency,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      // Trash Icon (Delete)
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          splashRadius: 18,
                          tooltip: 'Xóa đơn hàng',
                          onPressed: () {
                            if (originalIndex != -1) {
                              _deleteOrder(originalIndex);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: const Text(
        'Số 8, Tôn Thất Thuyết, Cầu Giấy, Hà Nội',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  color: Colors.white,
  fontSize: 13,
  fontWeight: FontWeight.bold,
);
