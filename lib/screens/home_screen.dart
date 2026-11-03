import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/database_helper.dart';
import '../models/transaction_item.dart';
import '../utils/currency_format.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToTransactions;

  const HomeScreen({super.key, required this.onNavigateToTransactions});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  Map<String, double> _expenseByCategory = {};
  List<TransactionItem> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);

    final income = await DatabaseHelper.instance.getTotalByType('income');
    final expense = await DatabaseHelper.instance.getTotalByType('expense');
    final categories = await DatabaseHelper.instance.getExpenseByCategory();
    final recent = await DatabaseHelper.instance.getRecentTransactions(limit: 5);

    if (mounted) {
      setState(() {
        _totalIncome = income;
        _totalExpense = expense;
        _expenseByCategory = categories;
        _recentTransactions = recent;
        _isLoading = false;
      });
    }
  }

  double get _balance => _totalIncome - _totalExpense;

  final List<Color> _chartColors = [
    Colors.deepOrange,
    Colors.blue,
    Colors.purple,
    Colors.amber,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Saldo Utama
            _buildBalanceCard(),
            const SizedBox(height: 18),

            // Bagian Grafik
            _buildChartsSection(),
            const SizedBox(height: 20),

            // Transaksi Terkini
            _buildRecentTransactionsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Saldo',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            FormatHelper.rupiah(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_downward, color: Colors.greenAccent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pemasukan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          FormatHelper.rupiah(_totalIncome),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          FormatHelper.rupiah(_totalExpense),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grafik Keuangan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // 1. Bar Chart: Pemasukan vs Pengeluaran
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perbandingan Arus Kas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: (_totalIncome == 0 && _totalExpense == 0)
                      ? const Center(
                          child: Text(
                            'Belum ada transaksi untuk grafik',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (_totalIncome > _totalExpense ? _totalIncome : _totalExpense) * 1.25,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final label = group.x == 0 ? 'Pemasukan' : 'Pengeluaran';
                                  return BarTooltipItem(
                                    '$label\n${FormatHelper.rupiah(rod.toY)}',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    if (val.toInt() == 0) {
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
                                      );
                                    } else if (val.toInt() == 1) {
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: _totalIncome,
                                    color: Colors.teal,
                                    width: 32,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: _totalExpense,
                                    color: Colors.redAccent,
                                    width: 32,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. Donut/Pie Chart: Kategori Pengeluaran
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distribusi Pengeluaran per Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 16),
                _expenseByCategory.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Belum ada data pengeluaran',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: _buildPieSections(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPieLegend(),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    int i = 0;
    return _expenseByCategory.entries.map((entry) {
      final color = _chartColors[i % _chartColors.length];
      i++;
      final pct = _totalExpense > 0 ? (entry.value / _totalExpense * 100) : 0.0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 46,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildPieLegend() {
    int i = 0;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _expenseByCategory.entries.map((entry) {
        final color = _chartColors[i % _chartColors.length];
        i++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key}: ${FormatHelper.rupiah(entry.value)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaksi Terkini',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: widget.onNavigateToTransactions,
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (_recentTransactions.isEmpty)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada transaksi tercatat.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _recentTransactions[index];
                final isIncome = item.isIncome;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIncome ? Colors.teal.withAlpha(40) : Colors.redAccent.withAlpha(40),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncome ? Colors.teal : Colors.redAccent,
                      size: 20,
                    ),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.category} • ${FormatHelper.formatDate(item.date)}'),
                  trailing: Text(
                    '${isIncome ? '+' : '-'} ${FormatHelper.rupiah(item.amount)}',
                    style: TextStyle(
                      color: isIncome ? Colors.teal : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

