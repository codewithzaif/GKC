class Fund {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;

  Fund({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      isIncome: json['isIncome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'isIncome': isIncome,
    };
  }
} 