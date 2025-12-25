import 'package:hive/hive.dart';
import 'enums.dart';

part 'ocr_scan.g.dart';

@HiveType(typeId: 16)
class OCRScan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  String? extractedText;

  @HiveField(3)
  String? parsedVendor;

  @HiveField(4)
  double? parsedAmount;

  @HiveField(5)
  DateTime? parsedDate;

  @HiveField(6)
  OCRStatus status;

  @HiveField(7)
  double? confidence;

  @HiveField(8)
  final DateTime createdAt;

  OCRScan({
    required this.id,
    required this.imagePath,
    this.extractedText,
    this.parsedVendor,
    this.parsedAmount,
    this.parsedDate,
    this.status = OCRStatus.pending,
    this.confidence,
    required this.createdAt,
  });

  OCRScan copyWith({
    String? imagePath,
    String? extractedText,
    String? parsedVendor,
    double? parsedAmount,
    DateTime? parsedDate,
    OCRStatus? status,
    double? confidence,
  }) {
    return OCRScan(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      parsedVendor: parsedVendor ?? this.parsedVendor,
      parsedAmount: parsedAmount ?? this.parsedAmount,
      parsedDate: parsedDate ?? this.parsedDate,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt,
    );
  }

  /// Check if OCR scan was successful
  bool get isSuccessful => status == OCRStatus.processed && parsedAmount != null;

  /// Get confidence as percentage string
  String get confidencePercent =>
      confidence != null ? '${(confidence! * 100).toStringAsFixed(0)}%' : 'N/A';
}
