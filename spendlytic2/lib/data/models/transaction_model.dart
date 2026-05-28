class TransactionModel {
  final int? id; // Matches 'id' (int8), nullable for new items
  final String userId; // Matches 'user_id'
  final String title; // Matches 'title'
  final double amount; // Matches 'amount'
  final String category; // Matches 'category'
  final DateTime date; // Matches 'transaction_date'

  TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      title: json['title'] ?? 'Untitled',
      // Safely handle int or double from JSON
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'General',
      date: DateTime.tryParse(json['transaction_date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'transaction_date': date.toIso8601String(),
    };

    // Only include ID if we are updating an existing row
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
