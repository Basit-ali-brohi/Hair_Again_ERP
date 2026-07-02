// core/utils — currency (PKR), date & misc formatters shared across the ERP.

String money(num v) => 'PKR ${_thousands(v)}';

String _thousands(num v) {
  final n = v.round();
  final s = n.abs().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}$b';
}

String moneyShort(num v) {
  if (v >= 10000000) return 'PKR ${(v / 10000000).toStringAsFixed(2)} Cr';
  if (v >= 100000) return 'PKR ${(v / 100000).toStringAsFixed(2)} Lac';
  if (v >= 1000) return 'PKR ${(v / 1000).toStringAsFixed(1)}K';
  return 'PKR ${v.toStringAsFixed(0)}';
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthsFull = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String prettyDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';
String prettyShort(DateTime d) => '${d.day} ${_months[d.month - 1]}';
String monthName(int m) => _monthsFull[m - 1];

String timeLabel(DateTime d) {
  final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}

String roman(int n) {
  const r = ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];
  return (n >= 1 && n <= 7) ? r[n] : '$n';
}

String norwoodDesc(int n) => switch (n) {
      1 => 'Minimal / no recession',
      2 => 'Slight temporal recession',
      3 => 'Deeper recession, early crown',
      4 => 'Pronounced recession + crown thinning',
      5 => 'Widening bald areas, thin bridge',
      6 => 'Bridge gone, large bald zones',
      7 => 'Most advanced — band of hair only',
      _ => '',
    };
