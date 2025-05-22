class SystemLog {
  final DateTime timestamp;
  final String level;
  final String message;

  SystemLog({
    required this.timestamp,
    required this.level,
    required this.message,
  });
}