import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat('#,##0.00', 'fr');
final _dateFormat = DateFormat('dd/MM/yyyy');
final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
final _numberFormat = NumberFormat('#,##0.###', 'fr');

String formatCurrency(double? value) {
  if (value == null) return '0,00 DA';
  return '${_currencyFormat.format(value)} DA';
}

String formatDate(String? dateStr) {
  if (dateStr == null) return '—';
  try {
    final d = DateTime.parse(dateStr);
    return _dateFormat.format(d);
  } catch (_) {
    return dateStr;
  }
}

String formatDateTime(String? dateStr) {
  if (dateStr == null) return '—';
  try {
    final d = DateTime.parse(dateStr);
    return _dateTimeFormat.format(d);
  } catch (_) {
    return dateStr;
  }
}

String formatNumber(double? value) {
  if (value == null) return '0';
  return _numberFormat.format(value);
}

String formatStockValue(dynamic val) {
  if (val == null) return '0';
  final d = double.tryParse(val.toString());
  if (d == null) return val.toString();
  if (d == d.roundToDouble()) return d.toInt().toString();
  return _numberFormat.format(d);
}
