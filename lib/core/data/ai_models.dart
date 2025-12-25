/// AI Provider types
enum AIProvider {
  google,
  openai,
  anthropic,
}

/// AI Model configuration
class AIModel {
  final String id;
  final String name;
  final String displayName;
  final AIProvider provider;
  final String description;

  const AIModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.provider,
    required this.description,
  });

  String get providerName {
    switch (provider) {
      case AIProvider.google:
        return 'Google';
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.anthropic:
        return 'Anthropic';
    }
  }

  String get providerIcon {
    switch (provider) {
      case AIProvider.google:
        return '🔷';
      case AIProvider.openai:
        return '🟢';
      case AIProvider.anthropic:
        return '🟠';
    }
  }
}

/// Available AI Models
class AIModels {
  static const List<AIModel> all = [
    // Google Models
    AIModel(
      id: 'gemini-2.5-pro',
      name: 'gemini-2.5-pro',
      displayName: 'Gemini 2.5 Pro',
      provider: AIProvider.google,
      description: 'Most capable Gemini model for complex tasks',
    ),
    AIModel(
      id: 'gemini-2.5-flash',
      name: 'gemini-2.5-flash',
      displayName: 'Gemini 2.5 Flash',
      provider: AIProvider.google,
      description: 'Fast and efficient for everyday tasks',
    ),

    // OpenAI Models
    AIModel(
      id: 'gpt-4o',
      name: 'gpt-4o',
      displayName: 'GPT-4o',
      provider: AIProvider.openai,
      description: 'Multimodal model with vision capabilities',
    ),
    AIModel(
      id: 'gpt-5',
      name: 'gpt-5',
      displayName: 'GPT-5',
      provider: AIProvider.openai,
      description: 'Latest and most advanced OpenAI model',
    ),

    // Anthropic Models
    AIModel(
      id: 'claude-sonnet-4.5',
      name: 'claude-sonnet-4.5',
      displayName: 'Claude Sonnet 4.5',
      provider: AIProvider.anthropic,
      description: 'Balanced performance and speed',
    ),
    AIModel(
      id: 'claude-haiku-4.5',
      name: 'claude-haiku-4.5',
      displayName: 'Claude Haiku 4.5',
      provider: AIProvider.anthropic,
      description: 'Fastest Claude model for quick tasks',
    ),
    AIModel(
      id: 'claude-opus-4.5',
      name: 'claude-opus-4.5',
      displayName: 'Claude Opus 4.5',
      provider: AIProvider.anthropic,
      description: 'Most powerful Claude model',
    ),
  ];

  /// Get model by ID
  static AIModel? getById(String id) {
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get models by provider
  static List<AIModel> getByProvider(AIProvider provider) {
    return all.where((m) => m.provider == provider).toList();
  }

  /// Get all providers
  static List<AIProvider> get providers => AIProvider.values;
}
