import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/fund.dart';
import '../services/database_service.dart';

class FundScreen extends StatefulWidget {
  const FundScreen({Key? key}) : super(key: key);

  @override
  _FundScreenState createState() => _FundScreenState();
}

class _FundScreenState extends State<FundScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Fund> _funds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFunds();
  }

  Future<void> _loadFunds() async {
    setState(() {
      _isLoading = true;
    });

    final funds = await _databaseService.getFunds();
    
    setState(() {
      _funds = funds..sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFunds,
              child: _funds.isEmpty
                  ? _buildEmptyState()
                  : _buildFundsList(),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddFundDialog(context),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_money,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No funds recorded yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showAddFundDialog(context),
            child: const Text('Add Fund Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFundsList() {
    return ListView.builder(
      itemCount: _funds.length,
      itemBuilder: (context, index) {
        final fund = _funds[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: fund.isIncome ? Colors.green : Colors.red,
              child: Icon(
                fund.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
            title: Text(fund.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fund.category),
                Text(
                  'Date: ${_formatDate(fund.date)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Text(
              '${fund.isIncome ? '+' : '-'}₹${fund.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: fund.isIncome ? Colors.green : Colors.red,
              ),
            ),
            onTap: () => _showFundDetailsDialog(context, fund),
            onLongPress: () => _showDeleteConfirmation(context, fund),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showAddFundDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    double amount = 0;
    String category = 'Maintenance';
    bool isIncome = true;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Fund Entry'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      title = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onSaved: (value) {
                      description = value ?? '';
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      amount = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: category,
                    items: const [
                      DropdownMenuItem(
                        value: 'Maintenance',
                        child: Text('Maintenance'),
                      ),
                      DropdownMenuItem(
                        value: 'Utilities',
                        child: Text('Utilities'),
                      ),
                      DropdownMenuItem(
                        value: 'Events',
                        child: Text('Events'),
                      ),
                      DropdownMenuItem(
                        value: 'Repairs',
                        child: Text('Repairs'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      category = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Transaction Type:'),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text('Income'),
                        selected: isIncome,
                        onSelected: (selected) {
                          setState(() {
                            isIncome = selected;
                          });
                        },
                        selectedColor: Colors.green.shade200,
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Expense'),
                        selected: !isIncome,
                        onSelected: (selected) {
                          setState(() {
                            isIncome = !selected;
                          });
                        },
                        selectedColor: Colors.red.shade200,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  
                  final fund = Fund(
                    id: const Uuid().v4(),
                    title: title,
                    description: description,
                    amount: amount,
                    date: DateTime.now(),
                    category: category,
                    isIncome: isIncome,
                  );
                  
                  await _databaseService.saveFund(fund);
                  await _loadFunds();
                  
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFundDetailsDialog(BuildContext context, Fund fund) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(fund.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${fund.category}'),
              const SizedBox(height: 8),
              Text(
                'Amount: ${fund.isIncome ? '+' : '-'}₹${fund.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: fund.isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text('Date: ${_formatDate(fund.date)}'),
              const SizedBox(height: 8),
              Text('Type: ${fund.isIncome ? 'Income' : 'Expense'}'),
              const SizedBox(height: 16),
              Text('Description:'),
              const SizedBox(height: 4),
              Text(
                fund.description.isEmpty ? 'No description provided' : fund.description,
                style: TextStyle(
                  color: fund.description.isEmpty ? Colors.grey : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Fund fund) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Fund Entry'),
          content: Text('Are you sure you want to delete "${fund.title}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                await _databaseService.deleteFund(fund.id);
                await _loadFunds();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
} 