# SubsCare - Subscription & Billing Management App

## Project Overview
A Flutter application to manage subscriptions, billing, orders (Debit/Credit) and maintain a personal ledger through three input methods: Manual, OCR, and AI.

---

## Tech Stack
| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| State Management | GetX |
| Local Storage | Hive |
| AI Model | Gemini 3.0 Flash |
| Notifications | Local Notifications |
| Authentication | Google Sign-In |
| OCR | Google ML Kit |

---

## App Architecture

### Navigation Structure
```
Bottom Navigation Bar (4 items + 1 FAB):
├── Dashboard (Home)
├── Subscriptions
├── [AI Button - Center FAB 1.5x size]
├── Transactions
└── Reports

Drawer (Occasional Tasks):
├── Profile & Settings
├── Categories Management
├── Backup & Restore
├── Reminders
├── OCR Scanner
├── Export Data
└── About & Help
```

### Dashboard Layout
```
┌─────────────────────────────┐
│      Analytics Summary      │
│  (Cards: Income/Expense/    │
│   Balance/Upcoming Bills)   │
├─────────────────────────────┤
│                             │
│     Ledger (Scrollable)     │
│   - Date-wise grouping      │
│   - Debit/Credit entries    │
│   - Quick filters           │
│                             │
└─────────────────────────────┘
```

---

## Phase-Wise Development Plan

### Phase 1: Project Foundation & Core Setup
> **Goal**: Set up project structure, dependencies, and basic navigation

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Initialize Flutter project with clean architecture | High |
| [ ] | Configure GetX for state management & routing | High |
| [ ] | Set up Hive database with required boxes | High |
| [ ] | Create base theme (light/dark mode support) | Medium |
| [ ] | Implement Bottom Navigation Bar with 4 tabs | High |
| [ ] | Create center AI FAB button (1.5x circular) | High |
| [ ] | Implement Drawer with menu items | Medium |
| [ ] | Set up folder structure (features-first approach) | High |

**Folder Structure:**
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── features/
│   ├── dashboard/
│   ├── subscriptions/
│   ├── transactions/
│   ├── reports/
│   ├── ai_assistant/
│   ├── ocr/
│   └── settings/
├── routes/
└── main.dart
```

---

### Phase 2: Data Models & Local Storage
> **Goal**: Define all data models and implement Hive persistence

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Create `Transaction` model (id, title, amount, type, category, date, notes, attachments) | High |
| [ ] | Create `Subscription` model (id, name, amount, frequency, nextDue, isAutoPay, reminder) | High |
| [ ] | Create `Category` model (id, name, icon, color, type) | High |
| [ ] | Create `Ledger` model (aggregated view model) | Medium |
| [ ] | Create `UserProfile` model | Medium |
| [ ] | Implement Hive adapters for all models | High |
| [ ] | Create repository layer for CRUD operations | High |
| [ ] | Add default categories (Food, Transport, Entertainment, Bills, etc.) | Medium |
| [ ] | Implement data migration strategy | Low |

**Transaction Model:**
```dart
enum TransactionType { debit, credit }
enum EntryMethod { manual, ocr, ai }

class Transaction {
  String id;
  String title;
  double amount;
  TransactionType type;
  String categoryId;
  DateTime dateTime;
  String? notes;
  List<String>? attachments;
  EntryMethod entryMethod;
  bool isRecurring;
  String? subscriptionId;
}
```

---

### Phase 3: Dashboard & Ledger
> **Goal**: Build the main dashboard with analytics and ledger view

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Create analytics summary cards (Total Income, Total Expense, Balance, Upcoming) | High |
| [ ] | Implement date range filter for analytics | Medium |
| [ ] | Build ledger list view with date-wise grouping | High |
| [ ] | Add debit/credit color coding (Red/Green) | High |
| [ ] | Implement pull-to-refresh | Medium |
| [ ] | Add quick filter chips (All, Debit, Credit, Today, This Week) | Medium |
| [ ] | Create transaction detail bottom sheet | Medium |
| [ ] | Implement search functionality | Medium |
| [ ] | Add empty state illustrations | Low |

---

### Phase 4: Manual Entry System
> **Goal**: Allow users to manually add transactions and subscriptions

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Create "Add Transaction" bottom sheet/page | High |
| [ ] | Implement amount input with calculator-style keypad | Medium |
| [ ] | Build category selector with icons | High |
| [ ] | Add date-time picker | High |
| [ ] | Implement notes/description field | Medium |
| [ ] | Add attachment picker (image/document) | Medium |
| [ ] | Create "Add Subscription" form | High |
| [ ] | Implement frequency selector (Daily, Weekly, Monthly, Yearly, Custom) | High |
| [ ] | Add auto-pay toggle | Medium |
| [ ] | Build reminder configuration | Medium |
| [ ] | Implement edit transaction functionality | High |
| [ ] | Add delete with confirmation | High |
| [ ] | Create duplicate transaction feature | Low |

---

### Phase 5: Subscriptions Management
> **Goal**: Complete subscription tracking with reminders

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Build subscriptions list view | High |
| [ ] | Add subscription cards with status indicators | High |
| [ ] | Implement subscription detail page | Medium |
| [ ] | Create upcoming payments section | High |
| [ ] | Add subscription pause/resume functionality | Medium |
| [ ] | Implement subscription history view | Medium |
| [ ] | Build subscription analytics (monthly spend by subscription) | Medium |
| [ ] | Add popular subscription templates (Netflix, Spotify, etc.) | Low |
| [ ] | Implement subscription grouping by category | Low |

---

### Phase 6: AI Assistant Integration
> **Goal**: Integrate Gemini 3.0 Flash for quick transaction entry

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Set up Gemini API configuration | High |
| [ ] | Create AI prompt composer bottom sheet | High |
| [ ] | Design chat-like input interface | High |
| [ ] | Implement natural language parsing for transactions | High |
| [ ] | Build AI response handler to extract transaction data | High |
| [ ] | Create confirmation dialog before saving AI-parsed transaction | High |
| [ ] | Add example prompts/suggestions | Medium |
| [ ] | Implement voice input option | Low |
| [ ] | Add transaction correction/editing after AI parse | Medium |
| [ ] | Create AI history/recent prompts | Low |
| [ ] | Handle offline scenarios gracefully | Medium |

**AI Prompt Examples:**
```
"Bought chips for 10 taka"
→ AI Response: Debit | BDT 10 | Category: Food | Title: Chips

"Received salary 50000"
→ AI Response: Credit | BDT 50,000 | Category: Income | Title: Salary

"Paid electricity bill 2500 yesterday"
→ AI Response: Debit | BDT 2,500 | Category: Bills | Title: Electricity Bill | Date: Yesterday
```

---

### Phase 7: OCR Scanner
> **Goal**: Implement bill/receipt scanning with data extraction

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Set up Google ML Kit Text Recognition | High |
| [ ] | Create camera/gallery picker interface | High |
| [ ] | Build image preview with crop functionality | Medium |
| [ ] | Implement text extraction from images | High |
| [ ] | Parse extracted text for amount, date, vendor | High |
| [ ] | Create review/edit screen for OCR results | High |
| [ ] | Add document storage for scanned bills | Medium |
| [ ] | Implement batch scanning | Low |
| [ ] | Add receipt templates for common vendors | Low |
| [ ] | Handle poor quality images with user feedback | Medium |

---

### Phase 8: Reports & Analytics
> **Goal**: Comprehensive financial reports and insights

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Create reports tab with multiple report types | High |
| [ ] | Build monthly expense breakdown (pie chart) | High |
| [ ] | Implement income vs expense trend (line chart) | High |
| [ ] | Add category-wise spending analysis | Medium |
| [ ] | Create subscription cost analysis | Medium |
| [ ] | Build custom date range reports | Medium |
| [ ] | Implement comparison with previous periods | Low |
| [ ] | Add spending patterns/insights | Low |
| [ ] | Create budget vs actual report | Low |
| [ ] | Implement PDF export for reports | Medium |

---

### Phase 9: Notifications & Reminders
> **Goal**: Local notifications for subscription reminders and bill due dates

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Set up flutter_local_notifications | High |
| [ ] | Implement subscription due date reminders | High |
| [ ] | Add custom reminder scheduling | Medium |
| [ ] | Create notification preferences in settings | Medium |
| [ ] | Implement recurring notifications | High |
| [ ] | Add notification actions (Mark Paid, Snooze, View) | Medium |
| [ ] | Build notification history | Low |
| [ ] | Handle notification permissions properly | High |

---

### Phase 10: User Profile & Settings
> **Goal**: User preferences, backup, and customization

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Implement Google Sign-In | High |
| [ ] | Create profile page | Medium |
| [ ] | Build settings page with all preferences | High |
| [ ] | Add currency selector (BDT as default) | High |
| [ ] | Implement theme toggle (Light/Dark/System) | Medium |
| [ ] | Create categories management (Add/Edit/Delete) | Medium |
| [ ] | Build backup to local storage | Medium |
| [ ] | Implement restore from backup | Medium |
| [ ] | Add export data (CSV/JSON) | Medium |
| [ ] | Implement app lock (PIN/Biometric) | Low |
| [ ] | Add onboarding screens for first-time users | Medium |

---

### Phase 11: Polish & Optimization
> **Goal**: Final touches, performance, and UX improvements

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Add loading states and skeletons | Medium |
| [ ] | Implement error handling with user-friendly messages | High |
| [ ] | Add haptic feedback for interactions | Low |
| [ ] | Optimize Hive queries for large datasets | Medium |
| [ ] | Implement lazy loading for lists | Medium |
| [ ] | Add animations and transitions | Low |
| [ ] | Create empty states for all screens | Medium |
| [ ] | Implement swipe actions on list items | Medium |
| [ ] | Add undo functionality for deletions | Medium |
| [ ] | Performance profiling and optimization | High |
| [ ] | Memory leak detection and fixes | High |

---

### Phase 12: Testing & Quality Assurance
> **Goal**: Comprehensive testing before release

| Status | Task | Priority |
|--------|------|----------|
| [ ] | Write unit tests for models | High |
| [ ] | Write unit tests for repositories | High |
| [ ] | Write unit tests for GetX controllers | High |
| [ ] | Implement widget tests for key screens | Medium |
| [ ] | Create integration tests for critical flows | Medium |
| [ ] | Manual QA testing checklist | High |
| [ ] | Test on multiple device sizes | High |
| [ ] | Test offline functionality | Medium |
| [ ] | Accessibility testing | Medium |
| [ ] | Fix all identified bugs | High |

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| [ ] | Idle/Not Started |
| [~] | In Progress/Doing |
| [?] | Testing/Review |
| [x] | Completed |
| [!] | Blocked/Issue |

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  get: ^4.6.6

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # AI Integration
  google_generative_ai: ^0.4.0

  # OCR
  google_mlkit_text_recognition: ^0.11.0

  # Notifications
  flutter_local_notifications: ^17.0.0

  # Authentication
  google_sign_in: ^6.2.1

  # UI Components
  fl_chart: ^0.66.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.2.2
  image_picker: ^1.0.7
  permission_handler: ^11.2.0
  path_provider: ^2.1.2
  share_plus: ^7.2.1
  url_launcher: ^6.2.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
```

---

## Quick Reference - Entry Methods

| Method | Use Case | Access Point |
|--------|----------|--------------|
| **Manual** | Digital subscriptions, planned expenses | + Button, Subscription Tab |
| **OCR** | Physical bills, receipts, invoices | Drawer → OCR Scanner |
| **AI** | Quick daily expenses, verbal transactions | Center FAB → Bottom Sheet |

---

## Color Scheme Suggestion

```
Primary: #6366F1 (Indigo)
Secondary: #8B5CF6 (Purple)
Success/Credit: #10B981 (Green)
Error/Debit: #EF4444 (Red)
Warning: #F59E0B (Amber)
Background: #F8FAFC (Light) / #0F172A (Dark)
Surface: #FFFFFF (Light) / #1E293B (Dark)
```

---

## Notes

1. **Currency**: Default to BDT (Bangladeshi Taka) with option to change
2. **Language**: English (can add Bengali localization later)
3. **Offline First**: All core features work offline, sync when online
4. **Privacy**: All data stored locally, Google Sign-In optional for backup

---

*Last Updated: December 21, 2025*
