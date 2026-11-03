import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_item.dart';
import '../db/database_helper.dart';

class TransactionDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const TransactionDialog({super.key, required this.onSaved});

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'expense'; // default expense
  String _selectedCategory = 'Makanan';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Kesehatan',
    'Lainnya',
  ];

  final List<String> _incomeCategories = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Penjualan',
    'Hadiah',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String newType) {
    setState(() {
      _type = newType;
      _selectedCategory = newType == 'income'
          ? _incomeCategories.first
          : _expenseCategories.first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final item = TransactionItem(
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _selectedCategory,
      date: dateStr,
    );

    await DatabaseHelper.instance.insertTransaction(item);
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_type == 'income' ? 'Pemasukan berhasil dicatat' : 'Pengeluaran berhasil dicatat'),
          backgroundColor: _type == 'income' ? Colors.teal : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'income' ? _incomeCategories : _expenseCategories;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catat Transaksi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Toggle Pemasukan / Pengeluaran
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Pengeluaran')),
                        selected: _type == 'expense',
                        selectedColor: Colors.redAccent.withAlpha(50),
                        labelStyle: TextStyle(
                          color: _type == 'expense' ? Colors.redAccent : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => _onTypeChanged('expense'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Pemasukan')),
                        selected: _type == 'income',
                        selectedColor: Colors.teal.withAlpha(50),
                        labelStyle: TextStyle(
                          color: _type == 'income' ? Colors.teal : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => _onTypeChanged('income'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nominal Input
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal (Rp)',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Masukkan nominal';
                    }
                    final numVal = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), ''));
                    if (numVal == null || numVal <= 0) {
                      return 'Nominal harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Judul / Catatan
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul / Keterangan',
                    hintText: _type == 'income' ? 'Contoh: Gaji Pokok' : 'Contoh: Beli Kopi Siang',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Masukkan judul transaksi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Kategori Dropdown
                DropdownButtonFormField<String>(
                  key: ValueKey(_type),
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  items: categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Date Picker Button
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20, color: Colors.blueGrey),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('dd MMMM yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Simpan Button
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == 'income' ? Colors.teal : Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

