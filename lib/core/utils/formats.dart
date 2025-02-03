String formatDateTime(DateTime dt) {
  // Ejemplo simplificado: "2023-09-05 07:30"
  final dateString = '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)}';
  final timeString = '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
  return '$dateString $timeString';
}

String formatDate(DateTime dt) {
  return '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)}';
}

String _twoDigits(int n) => n < 10 ? '0$n' : '$n';


