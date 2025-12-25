import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;

import '../../core/data/ai_models.dart';
import '../repositories/app_settings_repository.dart';
import '../repositories/category_repository.dart';
import '../models/models.dart';

/// Response from AI transaction parsing
class AITransactionResponse {
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryName;
  final Currency currency;
  final String? notes;
  final DateTime? dateTime;
  final bool success;
  final String? error;

  AITransactionResponse({
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryName,
    this.currency = Currency.BDT,
    this.notes,
    this.dateTime,
    this.success = true,
    this.error,
  });

  factory AITransactionResponse.error(String message) {
    return AITransactionResponse(
      title: '',
      amount: 0,
      type: TransactionType.debit,
      categoryName: '',
      currency: Currency.BDT,
      success: false,
      error: message,
    );
  }

  factory AITransactionResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Parse currency - default to BDT
      Currency currency = Currency.BDT;
      final currencyStr = (json['currency'] as String?)?.toUpperCase();
      if (currencyStr == 'USD' || currencyStr == 'DOLLAR' || currencyStr == 'DOLLARS') {
        currency = Currency.USD;
      }

      return AITransactionResponse(
        title: json['title'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        type: (json['type'] as String?)?.toLowerCase() == 'credit'
            ? TransactionType.credit
            : TransactionType.debit,
        categoryName: json['category'] as String? ?? 'Other',
        currency: currency,
        notes: json['notes'] as String?,
        dateTime: json['dateTime'] != null
            ? DateTime.tryParse(json['dateTime'] as String)
            : null,
        success: true,
      );
    } catch (e) {
      return AITransactionResponse.error('Failed to parse AI response: $e');
    }
  }
}

/// AI Service for processing natural language transactions
class AIService extends GetxService {
  late final AppSettingsRepository _settingsRepo;
  late final CategoryRepository _categoryRepo;

  /// System prompt for transaction parsing
  String get _systemPrompt {
    final categories = _categoryRepo.getActiveCategories();
    final categoryNames = categories.map((c) => c.name).join(', ');

    return '''You are a financial assistant that parses natural language transaction descriptions into structured JSON.

IMPORTANT: You must ONLY respond with valid JSON, no other text.

Available categories: $categoryNames

Parse the user's input and return a JSON object with this exact structure:
{
  "title": "Brief transaction title (e.g., 'Lunch at restaurant', 'Monthly salary')",
  "amount": <number - the transaction amount as a positive number>,
  "type": "debit" or "credit" (debit = expense/spending, credit = income/receiving),
  "category": "Best matching category name from the available list",
  "currency": "BDT" or "USD" (detect from input, default to "BDT" if not specified),
  "notes": "Any additional details or null",
  "dateTime": "ISO8601 date string if mentioned, otherwise null"
}

Rules:
1. "Bought", "Paid", "Spent", "Purchase", "কিনলাম", "দিলাম" → type: "debit"
2. "Received", "Got", "Earned", "Salary", "Income", "পেলাম" → type: "credit"
3. Amount should always be a positive number
4. Currency detection:
   - "taka", "টাকা", "BDT", "tk" → currency: "BDT"
   - "dollar", "dollars", "USD", "\$" → currency: "USD"
   - If no currency mentioned, default to "BDT"
5. Match category as closely as possible to the available list
6. If no date mentioned, set dateTime to null
7. Title should be concise but descriptive

Examples:
Input: "Bought coffee for 50 taka"
Output: {"title":"Coffee","amount":50,"type":"debit","category":"Food & Dining","currency":"BDT","notes":null,"dateTime":null}

Input: "Received 100 dollars freelance payment"
Output: {"title":"Freelance Payment","amount":100,"type":"credit","category":"Freelance","currency":"USD","notes":null,"dateTime":null}

Input: "৫০০০০ টাকা বেতন পেলাম"
Output: {"title":"Monthly Salary","amount":50000,"type":"credit","category":"Salary","currency":"BDT","notes":null,"dateTime":null}

Input: "Paid electricity bill 2500 yesterday"
Output: {"title":"Electricity Bill","amount":2500,"type":"debit","category":"Utilities","currency":"BDT","notes":null,"dateTime":"<yesterday's date in ISO8601>"}

Now parse the following input and respond with ONLY the JSON:''';
  }

  Future<AIService> init() async {
    _settingsRepo = Get.find<AppSettingsRepository>();
    _categoryRepo = Get.find<CategoryRepository>();
    return this;
  }

  /// Check if AI is configured
  bool get isConfigured {
    final settings = _settingsRepo.settings;
    return settings.selectedAIModelId != null &&
        settings.selectedAIModelId!.isNotEmpty &&
        settings.aiApiKey != null &&
        settings.aiApiKey!.isNotEmpty;
  }

  /// Get current AI model
  AIModel? get currentModel {
    final modelId = _settingsRepo.settings.selectedAIModelId;
    if (modelId == null) return null;
    return AIModels.getById(modelId);
  }

  /// Parse transaction from text
  Future<AITransactionResponse> parseTransaction(String input) async {
    if (!isConfigured) {
      return AITransactionResponse.error('AI not configured. Please set up your AI model and API key in Settings.');
    }

    final model = currentModel;
    if (model == null) {
      return AITransactionResponse.error('Selected AI model not found.');
    }

    try {
      String response;

      switch (model.provider) {
        case AIProvider.google:
          response = await _callGemini(input);
          break;
        case AIProvider.openai:
          response = await _callOpenAI(input);
          break;
        case AIProvider.anthropic:
          response = await _callAnthropic(input);
          break;
      }

      // Parse JSON from response
      final jsonStr = _extractJson(response);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AITransactionResponse.fromJson(json);
    } catch (e) {
      return AITransactionResponse.error('AI processing failed: $e');
    }
  }

  /// Parse transaction from image
  Future<AITransactionResponse> parseTransactionFromImage(Uint8List imageBytes) async {
    if (!isConfigured) {
      return AITransactionResponse.error('AI not configured. Please set up your AI model and API key in Settings.');
    }

    final model = currentModel;
    if (model == null) {
      return AITransactionResponse.error('Selected AI model not found.');
    }

    try {
      String response;

      switch (model.provider) {
        case AIProvider.google:
          response = await _callGeminiWithImage(imageBytes);
          break;
        case AIProvider.openai:
          response = await _callOpenAIWithImage(imageBytes);
          break;
        case AIProvider.anthropic:
          response = await _callAnthropicWithImage(imageBytes);
          break;
      }

      final jsonStr = _extractJson(response);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AITransactionResponse.fromJson(json);
    } catch (e) {
      return AITransactionResponse.error('AI image processing failed: $e');
    }
  }

  /// Extract JSON from response (handles markdown code blocks)
  String _extractJson(String response) {
    // Remove markdown code blocks if present
    var cleaned = response.trim();

    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    return cleaned.trim();
  }

  /// Call Google Gemini API
  Future<String> _callGemini(String input) async {
    final apiKey = _settingsRepo.settings.aiApiKey!;
    final modelName = currentModel!.name;

    final model = gemini.GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: gemini.Content.text(_systemPrompt),
    );

    final response = await model.generateContent([
      gemini.Content.text(input),
    ]);

    return response.text ?? '';
  }

  /// Call Gemini with image
  Future<String> _callGeminiWithImage(Uint8List imageBytes) async {
    final apiKey = _settingsRepo.settings.aiApiKey!;
    final modelName = currentModel!.name;

    final model = gemini.GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: gemini.Content.text(
        '$_systemPrompt\n\nExtract transaction information from this receipt/document image:',
      ),
    );

    final response = await model.generateContent([
      gemini.Content.multi([
        gemini.DataPart('image/jpeg', imageBytes),
        gemini.TextPart('Extract the transaction details from this image.'),
      ]),
    ]);

    return response.text ?? '';
  }

  /// Call OpenAI API
  Future<String> _callOpenAI(String input) async {
    final apiKey = _settingsRepo.settings.aiApiKey!;
    final modelName = currentModel!.name;

    OpenAI.apiKey = apiKey;

    final response = await OpenAI.instance.chat.create(
      model: modelName,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(_systemPrompt),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(input),
          ],
        ),
      ],
    );

    return response.choices.first.message.content?.first.text ?? '';
  }

  /// Call OpenAI with image
  Future<String> _callOpenAIWithImage(Uint8List imageBytes) async {
    final apiKey = _settingsRepo.settings.aiApiKey!;
    final modelName = currentModel!.name;

    OpenAI.apiKey = apiKey;

    final base64Image = base64Encode(imageBytes);

    final response = await OpenAI.instance.chat.create(
      model: modelName,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              '$_systemPrompt\n\nExtract transaction information from this receipt/document image:',
            ),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
              'data:image/jpeg;base64,$base64Image',
            ),
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              'Extract the transaction details from this image.',
            ),
          ],
        ),
      ],
    );

    return response.choices.first.message.content?.first.text ?? '';
  }

  /// Call Anthropic Claude API
  Future<String> _callAnthropic(String input) async {
    final apiKey = _settingsRepo.settings.aiApiKey!;
    final modelName = currentModel!.name;

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': modelName,
        'max_tokens': 1024,
        'system': _systemPrompt,
        'messages': [
          {'role': 'user', 'content': input},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Anthropic API error: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['content'] as List;
    if (content.isNotEmpty) {
      return content.first['text'] as String? ?? '';
    }
    return '';
  }

  /// Call Anthropic with image
  Future<String> _callAnthropicWithImage(Uint8List imageBytes) async {
    final apiKey = _settingsRepo.settings.aiApiKey!;
    final modelName = currentModel!.name;

    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': modelName,
        'max_tokens': 1024,
        'system': '$_systemPrompt\n\nExtract transaction information from this receipt/document image:',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text': 'Extract the transaction details from this image.',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Anthropic API error: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['content'] as List;
    if (content.isNotEmpty) {
      return content.first['text'] as String? ?? '';
    }
    return '';
  }
}
