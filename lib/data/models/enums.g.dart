// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 0;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.debit;
      case 1:
        return TransactionType.credit;
      default:
        return TransactionType.debit;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.debit:
        writer.writeByte(0);
        break;
      case TransactionType.credit:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EntryMethodAdapter extends TypeAdapter<EntryMethod> {
  @override
  final int typeId = 1;

  @override
  EntryMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EntryMethod.manual;
      case 1:
        return EntryMethod.ocr;
      case 2:
        return EntryMethod.ai;
      default:
        return EntryMethod.manual;
    }
  }

  @override
  void write(BinaryWriter writer, EntryMethod obj) {
    switch (obj) {
      case EntryMethod.manual:
        writer.writeByte(0);
        break;
      case EntryMethod.ocr:
        writer.writeByte(1);
        break;
      case EntryMethod.ai:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FrequencyAdapter extends TypeAdapter<Frequency> {
  @override
  final int typeId = 2;

  @override
  Frequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Frequency.daily;
      case 1:
        return Frequency.weekly;
      case 2:
        return Frequency.monthly;
      case 3:
        return Frequency.yearly;
      case 4:
        return Frequency.custom;
      default:
        return Frequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, Frequency obj) {
    switch (obj) {
      case Frequency.daily:
        writer.writeByte(0);
        break;
      case Frequency.weekly:
        writer.writeByte(1);
        break;
      case Frequency.monthly:
        writer.writeByte(2);
        break;
      case Frequency.yearly:
        writer.writeByte(3);
        break;
      case Frequency.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryTypeAdapter extends TypeAdapter<CategoryType> {
  @override
  final int typeId = 3;

  @override
  CategoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CategoryType.debit;
      case 1:
        return CategoryType.credit;
      case 2:
        return CategoryType.both;
      default:
        return CategoryType.debit;
    }
  }

  @override
  void write(BinaryWriter writer, CategoryType obj) {
    switch (obj) {
      case CategoryType.debit:
        writer.writeByte(0);
        break;
      case CategoryType.credit:
        writer.writeByte(1);
        break;
      case CategoryType.both:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderTypeAdapter extends TypeAdapter<ReminderType> {
  @override
  final int typeId = 4;

  @override
  ReminderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderType.none;
      case 1:
        return ReminderType.oneDay;
      case 2:
        return ReminderType.threeDays;
      case 3:
        return ReminderType.oneWeek;
      default:
        return ReminderType.none;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderType obj) {
    switch (obj) {
      case ReminderType.none:
        writer.writeByte(0);
        break;
      case ReminderType.oneDay:
        writer.writeByte(1);
        break;
      case ReminderType.threeDays:
        writer.writeByte(2);
        break;
      case ReminderType.oneWeek:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OCRStatusAdapter extends TypeAdapter<OCRStatus> {
  @override
  final int typeId = 5;

  @override
  OCRStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OCRStatus.pending;
      case 1:
        return OCRStatus.processed;
      case 2:
        return OCRStatus.failed;
      default:
        return OCRStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, OCRStatus obj) {
    switch (obj) {
      case OCRStatus.pending:
        writer.writeByte(0);
        break;
      case OCRStatus.processed:
        writer.writeByte(1);
        break;
      case OCRStatus.failed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OCRStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderActionAdapter extends TypeAdapter<ReminderAction> {
  @override
  final int typeId = 6;

  @override
  ReminderAction read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderAction.none;
      case 1:
        return ReminderAction.paid;
      case 2:
        return ReminderAction.snoozed;
      default:
        return ReminderAction.none;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderAction obj) {
    switch (obj) {
      case ReminderAction.none:
        writer.writeByte(0);
        break;
      case ReminderAction.paid:
        writer.writeByte(1);
        break;
      case ReminderAction.snoozed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FileTypeAdapter extends TypeAdapter<FileType> {
  @override
  final int typeId = 7;

  @override
  FileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FileType.image;
      case 1:
        return FileType.pdf;
      case 2:
        return FileType.doc;
      default:
        return FileType.image;
    }
  }

  @override
  void write(BinaryWriter writer, FileType obj) {
    switch (obj) {
      case FileType.image:
        writer.writeByte(0);
        break;
      case FileType.pdf:
        writer.writeByte(1);
        break;
      case FileType.doc:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 8;

  @override
  AppThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeMode.light;
      case 1:
        return AppThemeMode.dark;
      case 2:
        return AppThemeMode.system;
      default:
        return AppThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    switch (obj) {
      case AppThemeMode.light:
        writer.writeByte(0);
        break;
      case AppThemeMode.dark:
        writer.writeByte(1);
        break;
      case AppThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BackupFrequencyAdapter extends TypeAdapter<BackupFrequency> {
  @override
  final int typeId = 9;

  @override
  BackupFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BackupFrequency.manual;
      case 1:
        return BackupFrequency.daily;
      case 2:
        return BackupFrequency.weekly;
      default:
        return BackupFrequency.manual;
    }
  }

  @override
  void write(BinaryWriter writer, BackupFrequency obj) {
    switch (obj) {
      case BackupFrequency.manual:
        writer.writeByte(0);
        break;
      case BackupFrequency.daily:
        writer.writeByte(1);
        break;
      case BackupFrequency.weekly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubscriptionTypeAdapter extends TypeAdapter<SubscriptionType> {
  @override
  final int typeId = 19;

  @override
  SubscriptionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionType.expense;
      case 1:
        return SubscriptionType.income;
      default:
        return SubscriptionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionType obj) {
    switch (obj) {
      case SubscriptionType.expense:
        writer.writeByte(0);
        break;
      case SubscriptionType.income:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final int typeId = 20;

  @override
  Currency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Currency.USD;
      case 1:
        return Currency.BDT;
      default:
        return Currency.USD;
    }
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    switch (obj) {
      case Currency.USD:
        writer.writeByte(0);
        break;
      case Currency.BDT:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 21;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.dailySummary;
      case 1:
        return NotificationType.rateUpdate;
      case 2:
        return NotificationType.reminder;
      case 3:
        return NotificationType.system;
      default:
        return NotificationType.dailySummary;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.dailySummary:
        writer.writeByte(0);
        break;
      case NotificationType.rateUpdate:
        writer.writeByte(1);
        break;
      case NotificationType.reminder:
        writer.writeByte(2);
        break;
      case NotificationType.system:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
