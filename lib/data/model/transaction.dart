import 'dart:convert';

class Transaction {
  final int? id;
  final String transactionId;
  final String buyerName;
  final int drugId;
  final String drugName;
  final String drugCategory;
  final double drugPrice;
  final int quantity;
  final double totalCost;
  final String purchaseMethod; // 'langsung' or 'resep_dokter'
  final String? prescriptionNumber;
  final String? prescriptionImagePath;
  final String? additionalNotes;
  final DateTime purchaseDate;
  final String? status; // 'selesai' or 'dibatalkan'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.id,
    required this.transactionId,
    required this.buyerName,
    required this.drugId,
    required this.drugName,
    required this.drugCategory,
    required this.drugPrice,
    required this.quantity,
    required this.totalCost,
    this.purchaseMethod = 'langsung',
    this.prescriptionNumber,
    this.prescriptionImagePath,
    this.additionalNotes,
    required this.purchaseDate,
    this.status = 'selesai',
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat instance dari Map (database)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      transactionId: map['transaction_id'],
      buyerName: map['buyer_name'],
      drugId: map['drug_id'],
      drugName: map['drug_name'],
      drugCategory: map['drug_category'],
      drugPrice: map['drug_price']?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 0,
      totalCost: map['total_cost']?.toDouble() ?? 0.0,
      purchaseMethod: map['purchase_method'] ?? 'langsung',
      prescriptionNumber: map['prescription_number'],
      prescriptionImagePath: map['prescription_image_path'],
      additionalNotes: map['additional_notes'],
      purchaseDate: DateTime.parse(map['purchase_date']),
      status: map['status'] ?? 'selesai',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Convert instance ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'buyer_name': buyerName,
      'drug_id': drugId,
      'drug_name': drugName,
      'drug_category': drugCategory,
      'drug_price': drugPrice,
      'quantity': quantity,
      'total_cost': totalCost,
      'purchase_method': purchaseMethod,
      'prescription_number': prescriptionNumber,
      'prescription_image_path': prescriptionImagePath,
      'additional_notes': additionalNotes,
      'purchase_date': purchaseDate.toIso8601String(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert ke Map tanpa field yang auto-generated untuk insert
  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map.remove('updated_at');
    return map;
  }

  // Convert ke Map untuk update (tanpa created_at)
  Map<String, dynamic> toMapForUpdate() {
    final map = toMap();
    map.remove('id');
    map.remove('created_at');
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  // Factory constructor dari JSON
  factory Transaction.fromJson(String source) => Transaction.fromMap(json.decode(source));

  // Convert ke JSON
  String toJson() => json.encode(toMap());

  // Copy with method untuk membuat instance baru dengan perubahan
  Transaction copyWith({
    int? id,
    String? transactionId,
    String? buyerName,
    int? drugId,
    String? drugName,
    String? drugCategory,
    double? drugPrice,
    int? quantity,
    double? totalCost,
    String? purchaseMethod,
    String? prescriptionNumber,
    String? prescriptionImagePath,
    String? additionalNotes,
    DateTime? purchaseDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      buyerName: buyerName ?? this.buyerName,
      drugId: drugId ?? this.drugId,
      drugName: drugName ?? this.drugName,
      drugCategory: drugCategory ?? this.drugCategory,
      drugPrice: drugPrice ?? this.drugPrice,
      quantity: quantity ?? this.quantity,
      totalCost: totalCost ?? this.totalCost,
      purchaseMethod: purchaseMethod ?? this.purchaseMethod,
      prescriptionNumber: prescriptionNumber ?? this.prescriptionNumber,
      prescriptionImagePath: prescriptionImagePath ?? this.prescriptionImagePath,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method untuk mengecek apakah transaksi memerlukan resep
  bool get requiresPrescription => purchaseMethod == 'resep_dokter';

  // Helper method untuk format tanggal
  String get formattedPurchaseDate {
    return '${purchaseDate.day.toString().padLeft(2, '0')}/${purchaseDate.month.toString().padLeft(2, '0')}/${purchaseDate.year} ${purchaseDate.hour.toString().padLeft(2, '0')}:${purchaseDate.minute.toString().padLeft(2, '0')}';
  }

  // Helper method untuk format mata uang
  String get formattedTotalCost {
    return 'Rp ${totalCost.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  @override
  String toString() {
    return 'Transaction(id: $id, transactionId: $transactionId, buyerName: $buyerName, drugName: $drugName, totalCost: $totalCost, purchaseDate: $purchaseDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.transactionId == transactionId;
  }

  @override
  int get hashCode => transactionId.hashCode;
}