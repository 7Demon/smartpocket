import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/savings_goal.dart';
import '../utils/currency_format.dart';

class SavingsScreen extends StatefulWidget {
  final VoidCallback onDataChanged;

  const SavingsScreen({super.key, required this.onDataChanged});

  @override
  State<SavingsScreen> createState() => SavingsScreenState();
}

class SavingsScreenState extends State<SavingsScreen> {
  List<SavingsGoal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getSavingsGoals();
    if (mounted) {
      setState(() {
        _goals = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddGoalDialog() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Target Tabungan Baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Target',
                  hintText: 'Contoh: Beli Laptop Baru',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Masukkan nama target' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Nominal (Rp)',
                  prefixText: 'Rp ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Masukkan nominal target';
                  final numVal = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), ''));
                  if (numVal == null || numVal <= 0) return 'Nominal harus > 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final target = double.parse(amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
                final newGoal = SavingsGoal(
                  title: titleController.text.trim(),
                  targetAmount: target,
                  currentAmount: 0.0,
                );
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                await DatabaseHelper.instance.insertSavingsGoal(newGoal);
                if (!mounted) return;
                nav.pop();
                loadGoals();
                widget.onDataChanged();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Target tabungan berhasil ditambahkan')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDepositWithdrawDialog(SavingsGoal goal, bool isDeposit) async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isDeposit ? 'Tambah Setoran Tabungan' : 'Tarik Tabungan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target: ${goal.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Saldo saat ini: ${FormatHelper.rupiah(goal.currentAmount)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: isDeposit ? 'Nominal Setoran' : 'Nominal Penarikan',
                  prefixText: 'Rp ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Masukkan nominal';
                  final numVal = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), ''));
                  if (numVal == null || numVal <= 0) return 'Nominal harus > 0';
                  if (!isDeposit && numVal > goal.currentAmount) {
                    return 'Saldo tabungan tidak mencukupi';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDeposit ? Colors.teal : Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
                final newAmount = isDeposit
                    ? (goal.currentAmount + amount)
                    : (goal.currentAmount - amount);

                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                await DatabaseHelper.instance.updateSavingsAmount(goal.id!, newAmount);
                if (!mounted) return;
                nav.pop();
                loadGoals();
                widget.onDataChanged();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isDeposit ? 'Setoran berhasil ditambahkan' : 'Penarikan berhasil dicatat'),
                    backgroundColor: isDeposit ? Colors.teal : Colors.orange,
                  ),
                );
              }
            },
            child: Text(isDeposit ? 'Setor' : 'Tarik'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(SavingsGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Target?'),
        content: Text('Yakin ingin menghapus target "${goal.title}"?'),
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

    if (confirmed == true && goal.id != null) {
      await DatabaseHelper.instance.deleteSavingsGoal(goal.id!);
      loadGoals();
      widget.onDataChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target tabungan telah dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.savings_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada target tabungan',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Buat target tabungan untuk memotivasi rencana impianmu!',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadGoals,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: _goals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      final isComplete = goal.isCompleted;

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          isComplete ? Icons.check_circle : Icons.savings,
                                          color: isComplete ? Colors.green : Colors.indigo,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            goal.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                    onPressed: () => _confirmDelete(goal),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: goal.progress,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isComplete ? Colors.green : Colors.indigoAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Nominal and Percentage
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${FormatHelper.rupiah(goal.currentAmount)} / ${FormatHelper.rupiah(goal.targetAmount)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isComplete ? Colors.green.withAlpha(30) : Colors.indigo.withAlpha(30),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${goal.percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isComplete ? Colors.green : Colors.indigo,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Action buttons: Setor & Tarik
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showDepositWithdrawDialog(goal, true),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Setor'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.teal,
                                        side: const BorderSide(color: Colors.teal),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: goal.currentAmount > 0
                                          ? () => _showDepositWithdrawDialog(goal, false)
                                          : null,
                                      icon: const Icon(Icons.remove, size: 16),
                                      label: const Text('Tarik'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange,
                                        side: const BorderSide(color: Colors.orange),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.add_task),
        label: const Text('Target Baru'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}

