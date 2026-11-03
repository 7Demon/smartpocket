import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/transaction_item.dart';
import '../utils/currency_format.dart';
import '../widgets/transaction_dialog.dart';

class TransactionScreen extends StatefulWidget {
  final VoidCallback onDataChanged;

  const TransactionScreen({super.key, required this.onDataChanged});

  @override
  State<TransactionScreen> createState() => TransactionScreenState();
}

class TransactionScreenState extends State<TransactionScreen> {
  String _filter = 'all'; // 'all', 'income', 'expense'
  List<TransactionItem> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getTransactions(
      filterType: _filter == 'all' ? null : _filter,
    );
    if (mounted) {
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged(String newFilter) {
    setState(() {
      _filter = newFilter;
    });
    loadTransactions();
  }

  Future<void> _confirmDelete(TransactionItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text('Hapus "${item.title}" sebesar ${FormatHelper.rupiah(item.amount)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      await DatabaseHelper.instance.deleteTransaction(item.id!);
      loadTransactions();
      widget.onDataChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi telah dihapus')),
        );
      }
    }
  }

  void _openAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (_) => TransactionDialog(
        onSaved: () {
          loadTransactions();
          widget.onDataChanged();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pemasukan', 'income', activeColor: Colors.teal),
                const SizedBox(width: 8),
                _buildFilterChip('Pengeluaran', 'expense', activeColor: Colors.redAccent),
              ],
            ),
          ),
          const Divider(height: 1),

          // Transaction List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada transaksi ${_filter == 'income' ? 'pemasukan' : _filter == 'expense' ? 'pengeluaran' : ''}',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadTransactions,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _transactions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _transactions[index];
                            final isIncome = item.isIncome;
                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isIncome ? Colors.teal.withAlpha(40) : Colors.redAccent.withAlpha(40),
                                  child: Icon(
                                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isIncome ? Colors.teal : Colors.redAccent,
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                subtitle: Text('${item.category} • ${FormatHelper.formatDate(item.date)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${isIncome ? '+' : '-'} ${FormatHelper.rupiah(item.amount)}',
                                      style: TextStyle(
                                        color: isIncome ? Colors.teal : Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                      onPressed: () => _confirmDelete(item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTransactionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Catat Transaksi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, {Color? activeColor}) {
    final isSelected = _filter == value;
    final color = activeColor ?? Theme.of(context).colorScheme.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withAlpha(40),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => _onFilterChanged(value),
    );
  }
}
