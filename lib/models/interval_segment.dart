class IntervalSegment {
  final String id;
  final String label;
  final int seconds;

  IntervalSegment({
    required this.label,
    required this.seconds,
    String? id,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  IntervalSegment copyWith({String? label, int? seconds}) => IntervalSegment(
        id: id,
        label: label ?? this.label,
        seconds: seconds ?? this.seconds,
      );

  @override
  bool operator ==(Object other) =>
      other is IntervalSegment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
