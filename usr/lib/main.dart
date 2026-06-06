import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const FifoTrackerApp());
}

class FifoTrackerApp extends StatelessWidget {
  const FifoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIFO Document Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TrackerHomeScreen(),
      },
    );
  }
}

class DocumentItem {
  final String id;
  final String name;
  final DateTime dateAdded;
  int quantity;

  DocumentItem({
    required this.id,
    required this.name,
    required this.dateAdded,
    required this.quantity,
  });
}

class TrackerHomeScreen extends StatefulWidget {
  const TrackerHomeScreen({super.key});

  @override
  State<TrackerHomeScreen> createState() => _TrackerHomeScreenState();
}

class _TrackerHomeScreenState extends State<TrackerHomeScreen> {
  final List<DocumentItem> _inventory = [];
  final _uuid = const Uuid();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  void _addItem() {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) return;
    int? qty = int.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) return;

    setState(() {
      _inventory.add(DocumentItem(
        id: _uuid.v4(),
        name: _nameController.text,
        dateAdded: DateTime.now(),
        quantity: qty,
      ));
      // Ensure FIFO sorting by date (oldest first)
      _inventory.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    });

    _nameController.clear();
    _quantityController.clear();
    Navigator.of(context).pop();
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Document / Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _consumeItemsDialog() {
    final TextEditingController consumeNameController = TextEditingController();
    final TextEditingController consumeQtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Consume Items (FIFO)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: consumeNameController,
                decoration: const InputDecoration(labelText: 'Item Name to Consume'),
              ),
              TextField(
                controller: consumeQtyController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _consumeItem(consumeNameController.text, int.tryParse(consumeQtyController.text) ?? 0);
                Navigator.of(context).pop();
              },
              child: const Text('Consume'),
            ),
          ],
        );
      },
    );
  }

  void _consumeItem(String name, int amountToConsume) {
    if (amountToConsume <= 0 || name.isEmpty) return;

    setState(() {
      int remainingToConsume = amountToConsume;

      for (int i = 0; i < _inventory.length; i++) {
        if (_inventory[i].name.toLowerCase() == name.toLowerCase() && _inventory[i].quantity > 0) {
          if (_inventory[i].quantity <= remainingToConsume) {
            remainingToConsume -= _inventory[i].quantity;
            _inventory[i].quantity = 0;
          } else {
            _inventory[i].quantity -= remainingToConsume;
            remainingToConsume = 0;
            break;
          }
        }
      }

      // Remove empty batches
      _inventory.removeWhere((item) => item.quantity <= 0);
      
      if (remainingToConsume > 0) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough "$name" in inventory. Needed $remainingToConsume more.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIFO Inventory & Docs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.outbox),
            tooltip: 'Consume Items',
            onPressed: _consumeItemsDialog,
          )
        ],
      ),
      body: _inventory.isEmpty
          ? const Center(child: Text('No items in inventory.'))
          : ListView.builder(
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final item = _inventory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(item.quantity.toString())),
                    title: Text(item.name),
                    subtitle: Text('Added: ${DateFormat('yyyy-MM-dd HH:mm').format(item.dateAdded)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _inventory.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
