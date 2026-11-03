import 'package:intl/intl.dart';

class FormatHelper {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String rupiah(num amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String today() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }
}

