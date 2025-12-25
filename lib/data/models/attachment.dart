import 'package:hive/hive.dart';
import 'enums.dart';

part 'attachment.g.dart';

@HiveType(typeId: 15)
class Attachment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String? transactionId;

  @HiveField(2)
  String? ocrScanId;

  @HiveField(3)
  String filePath;

  @HiveField(4)
  String fileName;

  @HiveField(5)
  FileType fileType;

  @HiveField(6)
  int fileSize;

  @HiveField(7)
  final DateTime createdAt;

  Attachment({
    required this.id,
    this.transactionId,
    this.ocrScanId,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
  });

  Attachment copyWith({
    String? transactionId,
    String? ocrScanId,
    String? filePath,
    String? fileName,
    FileType? fileType,
    int? fileSize,
  }) {
    return Attachment(
      id: id,
      transactionId: transactionId ?? this.transactionId,
      ocrScanId: ocrScanId ?? this.ocrScanId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt,
    );
  }

  /// Get file size in human readable format
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
