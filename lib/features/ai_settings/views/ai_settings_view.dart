import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/ai_models.dart';
import '../controllers/ai_settings_controller.dart';

/// AI Settings view for configuring AI model and API key
class AISettingsView extends GetView<AISettingsController> {
  const AISettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ai_powered'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => controller.hasChanges.value
              ? TextButton(
                  onPressed: controller.isSaving.value ? null : controller.saveSettings,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'save'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            _buildInfoCard(),
            const SizedBox(height: 24),

            // Model Selection
            _buildSectionHeader('select_ai_model'.tr),
            const SizedBox(height: 12),
            _buildModelSelection(),
            const SizedBox(height: 24),

            // API Key Section
            _buildSectionHeader('api_key'.tr),
            const SizedBox(height: 12),
            _buildApiKeySection(),
            const SizedBox(height: 24),

            // Selected Model Info
            Obx(() => controller.selectedModel != null
                ? _buildSelectedModelInfo()
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ai_settings_title'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ai_settings_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildModelSelection() {
    final modelsByProvider = controller.modelsByProvider;

    return Column(
      children: AIProvider.values.map((provider) {
        final models = modelsByProvider[provider] ?? [];
        return _buildProviderSection(provider, models);
      }).toList(),
    );
  }

  Widget _buildProviderSection(AIProvider provider, List<AIModel> models) {
    final providerColor = controller.getProviderColor(provider);
    final providerName = controller.getProviderDisplayName(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: providerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                providerName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: providerColor,
                ),
              ),
            ],
          ),
        ),
        ...models.map((model) => _buildModelCard(model, providerColor)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildModelCard(AIModel model, Color providerColor) {
    return Obx(() {
      final isSelected = controller.selectedModelId.value == model.id;

      return GestureDetector(
        onTap: () => controller.selectModel(model.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? providerColor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? providerColor : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? providerColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? providerColor : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? providerColor : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildApiKeySection() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: controller.apiKeyController,
                obscureText: !controller.isApiKeyVisible.value,
                decoration: InputDecoration(
                  hintText: 'enter_api_key'.tr,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(Icons.key, color: Colors.grey.shade600),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          controller.isApiKeyVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: controller.toggleApiKeyVisibility,
                      ),
                      if (controller.apiKeyController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade600),
                          onPressed: controller.clearApiKey,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'api_key_hint'.tr,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ));
  }

  Widget _buildSelectedModelInfo() {
    final model = controller.selectedModel!;
    final providerColor = controller.getProviderColor(model.provider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: providerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: providerColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: providerColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'selected_model'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: providerColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('model_name'.tr, model.displayName),
          _buildInfoRow('provider'.tr, controller.getProviderDisplayName(model.provider)),
          _buildInfoRow('model_id'.tr, model.name),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
