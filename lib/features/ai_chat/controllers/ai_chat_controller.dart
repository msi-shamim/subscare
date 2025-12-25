import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/services/ai_service.dart';
import '../../../core/controllers/shell_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../reports/controllers/reports_controller.dart';

/// Controller for AI Chat page
class AIChatController extends GetxController {
  // Dependencies
  late final AIService _aiService;
  late final TransactionRepository _transactionRepo;
  late final CategoryRepository _categoryRepo;
  late final ShellController _shellController;

  // Speech recognition
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Text controller for the composer
  final composerController = TextEditingController();

  // Focus node for composer
  final composerFocusNode = FocusNode();

  // Reactive state
  final RxBool isRecording = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isListening = false.obs;
  final RxString composerText = ''.obs;
  final RxBool speechAvailable = false.obs;

  // AI Configuration state
  final RxBool isAIConfigured = false.obs;

  // Quick amount chips
  final List<QuickAmountChip> quickChips = [
    QuickAmountChip(label: '+50', amount: 50, isCredit: true),
    QuickAmountChip(label: '+100', amount: 100, isCredit: true),
    QuickAmountChip(label: '+500', amount: 500, isCredit: true),
    QuickAmountChip(label: '-50', amount: 50, isCredit: false),
    QuickAmountChip(label: '-100', amount: 100, isCredit: false),
    QuickAmountChip(label: '-500', amount: 500, isCredit: false),
  ];

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    _initSpeech();
    composerController.addListener(_onComposerChanged);
  }

  void _initDependencies() {
    _transactionRepo = Get.find<TransactionRepository>();
    _categoryRepo = Get.find<CategoryRepository>();
    _shellController = Get.find<ShellController>();

    // AI service might not be registered yet
    if (Get.isRegistered<AIService>()) {
      _aiService = Get.find<AIService>();
      _checkAIConfiguration();
    }
  }

  Future<bool> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (error) {
          isListening.value = false;
          debugPrint('Speech error: ${error.errorMsg}');
        },
      );
      speechAvailable.value = available;
      return available;
    } catch (e) {
      debugPrint('Speech init error: $e');
      speechAvailable.value = false;
      return false;
    }
  }

  void _checkAIConfiguration() {
    isAIConfigured.value = _aiService.isConfigured;
  }

  void _onComposerChanged() {
    composerText.value = composerController.text;
  }

  /// Check if send button should be enabled
  bool get canSend => composerText.value.trim().isNotEmpty && !isSending.value;

  /// Add quick amount to composer
  void addQuickAmount(QuickAmountChip chip) {
    final currentText = composerController.text;
    final prefix = chip.isCredit ? 'Received' : 'Spent';
    final newText = currentText.isEmpty
        ? '$prefix ${chip.amount} taka'
        : '$currentText, $prefix ${chip.amount} taka';
    composerController.text = newText;
    composerController.selection = TextSelection.fromPosition(
      TextPosition(offset: composerController.text.length),
    );
  }

  /// Toggle voice recording
  Future<void> toggleRecording() async {
    // Try to initialize if not available (permissions may have been granted)
    if (!speechAvailable.value) {
      final initialized = await _initSpeech();
      if (!initialized) {
        _shellController.showError('speech_not_available'.tr);
        return;
      }
    }

    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
    } else {
      try {
        isListening.value = true;
        await _speech.listen(
          onResult: (result) {
            composerController.text = result.recognizedWords;
            if (result.finalResult) {
              isListening.value = false;
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          localeId: Get.locale?.languageCode == 'bn' ? 'bn_BD' : 'en_US',
        );
      } catch (e) {
        isListening.value = false;
        _shellController.showError('speech_error'.tr);
        debugPrint('Speech listen error: $e');
      }
    }
  }

  /// Open camera for receipt/document scanning
  Future<void> openCamera() async {
    if (!Get.isRegistered<AIService>()) {
      _shellController.showError('ai_not_configured'.tr);
      return;
    }

    _checkAIConfiguration();
    if (!isAIConfigured.value) {
      _showConfigureAIDialog();
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        isSending.value = true;
        final bytes = await image.readAsBytes();
        await _processImage(bytes);
      }
    } catch (e) {
      _shellController.showError('camera_error'.tr);
    } finally {
      isSending.value = false;
    }
  }

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    if (!Get.isRegistered<AIService>()) {
      _shellController.showError('ai_not_configured'.tr);
      return;
    }

    _checkAIConfiguration();
    if (!isAIConfigured.value) {
      _showConfigureAIDialog();
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        isSending.value = true;
        final bytes = await image.readAsBytes();
        await _processImage(bytes);
      }
    } catch (e) {
      _shellController.showError('gallery_error'.tr);
    } finally {
      isSending.value = false;
    }
  }

  /// Process image with AI
  Future<void> _processImage(Uint8List imageBytes) async {
    final response = await _aiService.parseTransactionFromImage(imageBytes);

    if (response.success) {
      await _createTransactionFromAI(response);
    } else {
      _shellController.showError(response.error ?? 'ai_processing_failed'.tr);
    }
  }

  /// Send message to AI
  Future<void> sendMessage() async {
    if (!canSend) return;

    if (!Get.isRegistered<AIService>()) {
      _shellController.showError('ai_not_configured'.tr);
      return;
    }

    _checkAIConfiguration();
    if (!isAIConfigured.value) {
      _showConfigureAIDialog();
      return;
    }

    final message = composerController.text.trim();
    isSending.value = true;

    try {
      final response = await _aiService.parseTransaction(message);

      if (response.success) {
        await _createTransactionFromAI(response);
        composerController.clear();
      } else {
        _shellController.showError(response.error ?? 'ai_processing_failed'.tr);
      }
    } catch (e) {
      _shellController.showError('ai_error'.tr);
    } finally {
      isSending.value = false;
    }
  }

  /// Create transaction from AI response
  Future<void> _createTransactionFromAI(AITransactionResponse response) async {
    // Find matching category
    final categoryId = _findCategoryId(response.categoryName, response.type);

    final now = DateTime.now();
    final transaction = Transaction(
      id: const Uuid().v4(),
      title: response.title,
      amount: response.amount,
      type: response.type,
      categoryId: categoryId,
      dateTime: response.dateTime ?? now,
      notes: response.notes,
      entryMethod: EntryMethod.ai,
      isRecurring: false,
      createdAt: now,
      updatedAt: now,
      originalCurrency: response.currency,
    );

    await _transactionRepo.save(transaction.id, transaction);

    // Notify other controllers for reactive updates
    _notifyControllers();

    // Show success message
    _shellController.showSuccess('transaction_added_ai'.tr);

    // Show transaction summary
    Get.snackbar(
      response.type == TransactionType.credit ? 'income'.tr : 'expense'.tr,
      '${response.title}: ৳${response.amount.toStringAsFixed(0)}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: response.type == TransactionType.credit
          ? Colors.green.shade100
          : Colors.red.shade100,
      colorText: response.type == TransactionType.credit
          ? Colors.green.shade900
          : Colors.red.shade900,
      duration: const Duration(seconds: 3),
      icon: Icon(
        response.type == TransactionType.credit
            ? Icons.arrow_downward
            : Icons.arrow_upward,
        color: response.type == TransactionType.credit
            ? Colors.green.shade700
            : Colors.red.shade700,
      ),
    );
  }

  /// Find category ID from category name
  String _findCategoryId(String categoryName, TransactionType type) {
    final categories = type == TransactionType.credit
        ? _categoryRepo.getCreditCategories()
        : _categoryRepo.getDebitCategories();

    // Try exact match first
    for (final category in categories) {
      if (category.name.toLowerCase() == categoryName.toLowerCase()) {
        return category.id;
      }
    }

    // Try partial match
    for (final category in categories) {
      if (category.name.toLowerCase().contains(categoryName.toLowerCase()) ||
          categoryName.toLowerCase().contains(category.name.toLowerCase())) {
        return category.id;
      }
    }

    // Return first category as fallback (usually "Other" or similar)
    if (categories.isNotEmpty) {
      return categories.first.id;
    }

    // Ultimate fallback - get any active category
    final allCategories = _categoryRepo.getActiveCategories();
    return allCategories.isNotEmpty ? allCategories.first.id : 'default';
  }

  /// Notify other controllers for reactive updates
  void _notifyControllers() {
    // Refresh Dashboard
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadData();
    }

    // Refresh Reports
    if (Get.isRegistered<ReportsController>()) {
      Get.find<ReportsController>().loadData();
    }
  }

  /// Show dialog to configure AI
  void _showConfigureAIDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('ai_not_configured'.tr),
        content: Text('ai_configure_prompt'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/ai-powered');
            },
            child: Text('configure'.tr),
          ),
        ],
      ),
    );
  }

  /// Clear composer
  void clearComposer() {
    composerController.clear();
  }

  /// Refresh AI configuration state
  void refreshConfiguration() {
    if (Get.isRegistered<AIService>()) {
      _aiService = Get.find<AIService>();
      _checkAIConfiguration();
    }
  }

  @override
  void onClose() {
    composerController.dispose();
    composerFocusNode.dispose();
    _speech.stop();
    super.onClose();
  }
}

/// Model for quick amount chips
class QuickAmountChip {
  final String label;
  final double amount;
  final bool isCredit;

  const QuickAmountChip({
    required this.label,
    required this.amount,
    required this.isCredit,
  });
}
