# SubsCare

> Your Personal Accountant - A subscription & billing management app for tracking expenses, income, and recurring payments.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

SubsCare is a Flutter application designed to help you manage subscriptions, billing, and maintain a personal ledger. Track your finances through three convenient input methods:

- **Manual Entry** - Traditional form-based transaction input
- **OCR Scanner** - Scan receipts and bills for automatic data extraction
- **AI Assistant** - Natural language input powered by AI (Gemini, OpenAI, Claude)

## Features

### Core Features
- **Dashboard** - Analytics summary with income, expenses, balance, and upcoming bills
- **Transaction Management** - Track all debit/credit transactions with categories
- **Subscription Tracking** - Manage recurring payments with reminders
- **Multi-currency Support** - BDT and USD with automatic conversion
- **Reports & Analytics** - Visual charts and spending insights

### Input Methods
- **Manual Entry** - Full control with category selection, notes, and attachments
- **AI-Powered Input** - Just describe your transaction in natural language
  - *"Bought coffee for 50 taka"* → Automatically parsed and categorized
  - *"Received salary 50000"* → Credit transaction created
- **Voice Input** - Speak your transactions (Bengali & English supported)
- **Camera/Gallery** - Scan receipts for automatic data extraction

### Additional Features
- **Local Notifications** - Reminders for upcoming bills and subscriptions
- **Dark/Light Theme** - System-aware theming
- **Offline First** - All data stored locally with Hive
- **Backup & Restore** - Secure your financial data
- **Multi-language** - English and Bengali (বাংলা) support

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x |
| State Management | GetX |
| Local Storage | Hive |
| AI Integration | Gemini, OpenAI, Claude |
| Notifications | flutter_local_notifications |
| Charts | fl_chart |
| Speech-to-Text | speech_to_text |

## Screenshots

<!-- Add screenshots here -->
*Screenshots coming soon*

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/msi-shamim/subscare.git
   cd subscare
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### AI Configuration (Optional)

To use AI-powered transaction input:

1. Open the app and go to **Settings** → **AI-Powered**
2. Select your preferred AI provider (Gemini, OpenAI, or Claude)
3. Enter your API key
4. Start using natural language to add transactions!

## Project Structure

```
lib/
├── core/
│   ├── bindings/       # GetX dependency injection
│   ├── constants/      # App colors, strings, config
│   ├── controllers/    # Global controllers
│   ├── theme/          # App theming
│   └── translations/   # i18n translations
├── data/
│   ├── models/         # Hive data models
│   ├── repositories/   # Data access layer
│   └── services/       # Business logic services
├── features/
│   ├── ai_chat/        # AI assistant feature
│   ├── dashboard/      # Home dashboard
│   ├── notifications/  # Notification management
│   ├── profile/        # User profile
│   ├── reports/        # Analytics & reports
│   ├── settings/       # App settings
│   ├── subscriptions/  # Subscription management
│   └── transactions/   # Transaction management
├── routes/             # App routing
└── main.dart           # Entry point
```

## Color Scheme

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#6366F1` | Main brand color |
| Secondary | `#8B5CF6` | Accent elements |
| Credit/Income | `#10B981` | Positive amounts |
| Debit/Expense | `#EF4444` | Negative amounts |
| Warning | `#F59E0B` | Alerts & warnings |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**MSI Shamim** - [@msi-shamim](https://github.com/msi-shamim)

---

<p align="center">
  Made with ❤️ in Bangladesh
</p>
