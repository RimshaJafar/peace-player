class SpouseData {
  final String gender; // 'male' or 'female'
  final String? maritalStatus;
  final int wivesCount;
  final bool? husbandAlive;

  const SpouseData({
    required this.gender,
    this.maritalStatus,
    this.wivesCount = 0,
    this.husbandAlive,
  });

  SpouseData copyWith({
    String? gender,
    String? maritalStatus,
    int? wivesCount,
    bool? husbandAlive,
  }) {
    return SpouseData(
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      wivesCount: wivesCount ?? this.wivesCount,
      husbandAlive: husbandAlive ?? this.husbandAlive,
    );
  }
}
