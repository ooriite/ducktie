class TimeBlock {
  final String id;
  final String userId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;
  final bool isShared;
  final int position;

  TimeBlock({
    required this.id,
    required this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.notes,
    this.isShared = false,
    this.position = 0,
  });

  // Convert from Supabase row
  factory TimeBlock.fromJson(Map<String, dynamic> json) {
    return TimeBlock(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      notes: json['notes'] as String?,
      isShared: json['is_shared'] as bool? ?? false,
      position: json['position'] as int? ?? 0,
    );
  }

  // Convert to Supabase format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'notes': notes,
      'is_shared': isShared,
      'position': position,
    };
  }
}
