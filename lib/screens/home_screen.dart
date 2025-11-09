import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/atm_card.dart';
import '../models/transaction.dart';
import '../widgets/grid_menu_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<TransactionModel> _transactions = [
    TransactionModel('Coffee Shop', '-Rp 35.000', 'Food'),
    TransactionModel('Grab Ride', '-Rp 25.000', 'Travel'),
    TransactionModel('Salary', '+Rp 5.000.000', 'Income'),
  ];

  final Map<String, double> _balances = {
    'Bank A': 12_500_000,
    'Bank B': 5_350_000,
    'Bank C': 6_350_000,
    'Bank D': 9_000_000,
  };

  void _updateBalance(String bank, double amountChange) {
    setState(() {
      _balances[bank] = (_balances[bank] ?? 0) + amountChange;
    });
  }

  void _addTransaction(String title, String amount, String category) {
    setState(() {
      _transactions.insert(0, TransactionModel(title, amount, category));
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil dihapus')),
    );
  }

  void _handleMenuTap(String label) {
    switch (label) {
      case 'Top Up':
      case 'Transfer':
      case 'Transfer ke Bank':
      case 'Tarik Tunai':
      case 'Food':
        _showBankInputDialog(label);
        break;
      case 'Lihat Saldo':
        _showAllBalancesDialog();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fitur "$label" belum diaktifkan.')),
        );
    }
  }

  void _showBankInputDialog(String title) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    String? selectedBank;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBank,
                items: _balances.keys
                    .map((bank) => DropdownMenuItem(
                          value: bank,
                          child: Text(bank),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedBank = value;
                },
                decoration: const InputDecoration(labelText: 'Pilih Bank'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
              ),
              if (title != 'Tarik Tunai')
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final amountText = amountController.text.trim();
              if (amountText.isEmpty || selectedBank == null) return;

              final double? amount =
                  double.tryParse(amountText.replaceAll('.', '').replaceAll(',', ''));
              if (amount == null || amount <= 0) return;

              if (title == 'Tarik Tunai' && amount < 10000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Minimal penarikan adalah Rp 10.000'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              double amountChange = 0;
              String formattedAmount = '';
              String note = noteController.text.trim().isEmpty
                  ? title
                  : noteController.text.trim();

              if (title == 'Top Up') {
                amountChange = amount;
                formattedAmount = '+${_rupiahFormat.format(amount)}';
              } else {
                amountChange = -amount;
                formattedAmount = '-${_rupiahFormat.format(amount)}';
              }

              _updateBalance(selectedBank!, amountChange);
              _addTransaction(note, formattedAmount, title);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title berhasil untuk $selectedBank!')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAllBalancesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saldo Semua Bank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _balances.entries
              .map((e) => ListTile(
                    title: Text(e.key),
                    trailing: Text(_rupiahFormat.format(e.value)),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Warna tema per menu
    final List<Color> menuColors = [
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.redAccent,
      Colors.teal,
    ];

    final List<IconData> menuIcons = [
      Icons.account_balance_wallet,
      Icons.swap_horiz,
      Icons.account_balance,
      Icons.local_atm,
      Icons.fastfood,
      Icons.visibility,
    ];

    final List<String> menuLabels = [
      'Top Up',
      'Transfer',
      'Transfer ke Bank',
      'Tarik Tunai',
      'Food',
      'Lihat Saldo',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Finance Mate'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Cards',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // 🔹 Kartu ATM dengan efek shadow
            Center(
              child: SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var entry in _balances.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: AtmCard(
                          bankName: entry.key,
                          cardNumber: '**** ${entry.key.hashCode % 9000 + 1000}',
                          balance: _rupiahFormat.format(entry.value),
                          color1: Colors.deepPurple,
                          color2: Colors.orangeAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            const Text('Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // 🔹 Menu grid warna-warni
            GridView.builder(
              itemCount: menuLabels.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _handleMenuTap(menuLabels[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: menuColors[index].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: menuColors[index].withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: menuColors[index],
                          child: Icon(menuIcons[index],
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          menuLabels[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),
            const Text('Recent Transactions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // 🔹 Daftar transaksi lebih rapi & modern
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.amount.contains('+')
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      child: Icon(
                        transaction.amount.contains('+')
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction.amount.contains('+')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(transaction.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(transaction.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          transaction.amount,
                          style: TextStyle(
                            color: transaction.amount.contains('+')
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () => _deleteTransaction(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}