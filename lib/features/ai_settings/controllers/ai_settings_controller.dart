import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data/ai_models.dart';
import '../../../data/repositories/app_settings_repository.dart';

/// Controller for AI Settings page
class AISettingsController extends GetxController {
  late final AppSettingsRepository _settingsRepo;

  // Form controller
  final apiKeyController = TextEditingController();

  // Reactive state
  final RxString selectedModelId = ''.obs;
  final RxBool isApiKeyVisible = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasChanges = false.obs;

  // Get all available models
  List<AIModel> get allModels => AIModels.all;

  // Get models grouped by provider
  Map<AIProvider, List<AIModel>> get modelsByProvider {
    final Map<AIProvider, List<AIModel>> grouped = {};
    for (final provider in AIProvider.values) {
      grouped[provider] = AIModels.getByProvider(provider);
    }
    return grouped;
  }

  // Get selected model
  AIModel? get selectedModel {
    if (selectedModelId.value.isEmpty) return null;
    return AIModels.getById(selectedModelId.value);
  }

  // Check if API key is set
  bool get hasApiKey => apiKeyController.text.isNotEmpty;

  // Get provider name for display
  String getProviderDisplayName(AIProvider provider) {
    switch (provider) {
      case AIProvider.google:
        return 'Google AI';
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.anthropic:
        return 'Anthropic';
    }
  }

  // Get provider color
  Color getProviderColor(AIProvider provider) {
    switch (provider) {
      case AIProvider.google:
        return const Color(0xFF4285F4);
      case AIProvider.openai:
        return const Color(0xFF10A37F);
      case AIProvider.anthropic:
        return const Color(0xFFD97706);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _settingsRepo = Get.find<AppSettingsRepository>();
    _loadSettings();

    // Listen for changes
    apiKeyController.addListener(_onFieldChanged);
  }

  void _loadSettings() {
    final settings = _settingsRepo.settings;
    selectedModelId.value = settings.selectedAIModelId ?? '';
    apiKeyController.text = settings.aiApiKey ?? '';
    hasChanges.value = false;
  }

  void _onFieldChanged() {
    hasChanges.value = true;
  }

  /// Select AI model
  void selectModel(String modelId) {
    selectedModelId.value = modelId;
    hasChanges.value = true;
  }

  /// Toggle API key visibility
  void toggleApiKeyVisibility() {
    isApiKeyVisible.value = !isApiKeyVisible.value;
  }

  /// Save AI settings
  Future<void> saveSettings() async {
    if (selectedModelId.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'select_ai_model'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isSaving.value = true;
    try {
      await _settingsRepo.setAISettings(
        selectedModelId.value,
        apiKeyController.text.trim().isEmpty ? null : apiKeyController.text.trim(),
      );
      hasChanges.value = false;
      Get.snackbar(
        'success'.tr,
        'ai_settings_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'ai_settings_save_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Clear API key
  void clearApiKey() {
    apiKeyController.clear();
    hasChanges.value = true;
  }

  /// Reset to defaults
  void resetToDefaults() {
    selectedModelId.value = '';
    apiKeyController.clear();
    hasChanges.value = true;
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    super.onClose();
  }
}
