class ProgressModel {
  final String categoryId;
  final Set<String> completedIds;
  final int totalItems;

  const ProgressModel({
    required this.categoryId,
    required this.completedIds,
    required this.totalItems,
  });

  int get completedCount => completedIds.length;
  double get percent => totalItems == 0 ? 0 : completedCount / totalItems;
  bool get isCompleted => completedCount >= totalItems;

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      categoryId: json['categoryId'] as String,
      completedIds: Set<String>.from((json['completedIds'] as List? ?? [])),
      totalItems: json['totalItems'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'completedIds': completedIds.toList(),
    'totalItems': totalItems,
  };

  ProgressModel copyWith({Set<String>? completedIds}) {
    return ProgressModel(
      categoryId: categoryId,
      completedIds: completedIds ?? this.completedIds,
      totalItems: totalItems,
    );
  }
}
