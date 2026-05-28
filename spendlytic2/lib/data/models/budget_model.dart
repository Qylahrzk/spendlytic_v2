class BudgetModel {
  final int? id;
  final String userId;
  final String category;
  final double amount;
  final DateTime createdAt;

  BudgetModel({
    this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      category: json['category'] ?? 'General',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category': category,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
