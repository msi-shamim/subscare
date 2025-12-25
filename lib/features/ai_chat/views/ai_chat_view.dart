import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/ai_chat_controller.dart';

/// AI Chat view for natural language transaction input
class AIChatView extends GetView<AIChatController> {
  const AIChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildContentArea(),
          ),
          // Composer area
          _buildComposerArea(),
          // Quick chips
          _buildQuickChips(),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.secondary.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'ai_assistant_title'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'ai_assistant_subtitle'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Example prompts
          _buildExamplePrompts(),
        ],
      ),
    );
  }

  Widget _buildExamplePrompts() {
    final examples = [
      'ai_example_1'.tr,
      'ai_example_2'.tr,
      'ai_example_3'.tr,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'try_saying'.tr,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        ...examples.map((example) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  controller.composerController.text = example;
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          example,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildQuickChips() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'quick_add'.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.quickChips.map((chip) {
                  final isCredit = chip.isCredit;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        chip.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      backgroundColor: isCredit
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      side: BorderSide(
                        color: isCredit
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                      onPressed: () => controller.addQuickAmount(chip),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposerArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Camera button
            IconButton(
              icon: Icon(
                Icons.camera_alt_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: controller.openCamera,
              tooltip: 'camera'.tr,
            ),
            // Text field
            Expanded(
              child: TextField(
                controller: controller.composerController,
                focusNode: controller.composerFocusNode,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'ai_composer_hint'.tr,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            // Mic / Send button
            Obx(() {
              final hasText = controller.composerText.value.isNotEmpty;
              final isListening = controller.isListening.value;
              final isSending = controller.isSending.value;

              if (isSending) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (hasText) {
                // Send button
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: controller.sendMessage,
                    tooltip: 'send'.tr,
                  ),
                );
              }

              // Mic button
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: isListening
                    ? BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      )
                    : null,
                child: IconButton(
                  icon: Icon(
                    isListening ? Icons.stop : Icons.mic_outlined,
                    color: isListening ? Colors.red : Colors.grey.shade600,
                  ),
                  onPressed: controller.toggleRecording,
                  tooltip: isListening ? 'stop'.tr : 'mic'.tr,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
