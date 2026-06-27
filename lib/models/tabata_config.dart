class TabataConfig {
  final int exerciseSeconds;
  final int restSeconds;
  final int rounds;

  const TabataConfig({
    required this.exerciseSeconds,
    required this.restSeconds,
    required this.rounds,
  });

  factory TabataConfig.defaults() => const TabataConfig(
        exerciseSeconds: 20,
        restSeconds: 10,
        rounds: 8,
      );

  TabataConfig copyWith({
    int? exerciseSeconds,
    int? restSeconds,
    int? rounds,
  }) =>
      TabataConfig(
        exerciseSeconds: exerciseSeconds ?? this.exerciseSeconds,
        restSeconds: restSeconds ?? this.restSeconds,
        rounds: rounds ?? this.rounds,
      );

  int get totalSeconds => (exerciseSeconds + restSeconds) * rounds;
}
