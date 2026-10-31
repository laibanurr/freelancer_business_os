
<div align="center">

# 💼 Freelancer Business OS
### An All-in-One Operations & Billing Operating System for Solo Enterprises

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State_Management-Riverpod-blue?style=for-the-badge)](https://riverpod.dev)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFA000?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com)
[![Google Gemini](https://img.shields.io/badge/AI-Gemini_Flash-4F46E5?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![Tests](https://img.shields.io/badge/Unit_Tests-6_Passing-10B981?style=for-the-badge&logo=checkmarx&logoColor=white)](#-automated-testing-suite)

<p align="center">
  <b>A production-grade mobile & web application eliminating tool fragmentation for freelancers.</b><br/>
  Consolidates CRM, Contract Roadmaps, Cloud Stopwatch, Invoicing, and an AI CFO into one reactive workspace.
</p>

</div>

---

## 📌 Executive Summary & Problem Solved

Solo freelancers frequently juggle 5 to 6 disconnected tools (WhatsApp, Notion, Clockify, Excel, and PayPal) to manage their business. This fragmentation results in **revenue leakage** (up to 30% of billable hours go untracked) and **cash flow blindness** (unclear tax liability and uncollected receivables).

**Freelancer Business OS** resolves this by establishing a unified, reactive pipeline:
$$\text{Client (CRM)} \longrightarrow \text{Project (Contract)} \longrightarrow \text{Time Log (Stopwatch)} \longrightarrow \text{Invoice (PDF)} \longrightarrow \text{AI CFO (Grounded)}$$

---

## 🏛️ System Architecture

The application is structured strictly under the **Dependency Inversion Principle (SOLID)** and **Clean Architecture**. The UI layer has zero direct database imports, depending solely on abstract repository interfaces managed by Riverpod.
code
Code
PRESENTATION LAYER (UI)
    [ClientsScreen]   [ProjectsScreen]   [TimeEntriesScreen]   [InvoicesScreen]
                          │                     │
                          ▼                     ▼
                  RIVERPOD STATE MANAGEMENT LAYER
    [clientsStreamProvider]    [projectsStreamProvider]    [chatProvider]
                          │                     │
                          ▼                     ▼
                  REPOSITORY ABSTRACTION LAYER (SOLID)
    [ClientRepository]     [ProjectRepository]     [TimeEntryRepository]
    (Abstract interfaces enabling 100% offline unit-test mockability)
                          │                     │
                          ▼                     ▼
                INFRASTRUCTURE & SERVICE LAYER
    [FirebaseClientRepo]   [FirebaseProjectRepo]   [AiService]
             │                      │                    │
             ▼                      ▼                    ▼
    [Cloud Firestore]      [Firebase Auth]      [Google Gemini API]
code
Code
---

## 🌟 Key Engineering Highlights

### 1. 🛡️ Anti-Double-Billing Algorithm (`GenerateInvoiceScreen`)
Eliminates duplicate billing in distributed NoSQL Firestore using an idempotent set-difference filter:
* Queries all historical invoices for the project and flattens past billed IDs via `.expand((inv) => inv.timeEntryIds).toSet()`.
* Evaluates candidate completed time entries against the set in **$O(1)$ constant time**.
* Automatically halts compilation if no unbilled hours remain, preventing zero-dollar invoices.

### 2. 💵 Financial Precision Standard (`rateInCents`)
To prevent **IEEE 754 binary floating-point rounding errors** (e.g., `0.1 + 0.2 = 0.30000000000000004`), monetary values are never stored as `double`.
* All rates and invoice totals are stored as **integer cents (`rateInCents`)**.
* Currency is only converted to human-readable decimals (`(cents / 100).toStringAsFixed(2)`) at the presentation boundary.

### 3. ⏱️ Cloud-Synced Stopwatch (`TimeEntriesScreen`)
* Active sessions record `startTime: DateTime.now()` and `endTime: null` in Firestore.
* Elapsed duration is calculated against real-world UTC clocks: `DateTime.now().difference(startTime)`.
* Sessions persist and remain accurate even if the app closes or the mobile device restarts.
* Uses Riverpod's `StreamProvider.autoDispose.family` to automatically terminate database listeners upon screen exit.

### 4. 🤖 Grounded Gemini CFO Companion (`ChatScreen`)
* Employs **Context Injection**: dynamically calculates paid revenue, outstanding receivables, and active contracts from active Firestore streams and injects this live snapshot into the system prompt.
* Gemini answers financial questions rooted in the freelancer's actual bank ledger.

### 5. 📄 W3C Compliant Vector PDF Generation (`InvoicePdfService`)
* Uses `package:pdf` to compile headless A4 vector invoices.
* On Web, utilizes modern `package:web` and `dart:js_interop` to convert byte buffers into JavaScript Blobs and programmatically trigger browser downloads with automatic memory revocation (`URL.revokeObjectURL`).

---

## 🧪 Automated Testing Suite

The codebase includes targeted unit tests verifying core accounting algorithms, financial arithmetic, and fallback parsers under the **AAA (Arrange-Act-Assert)** pattern.

```bash
# Run the test suite:
flutter test
Verified Test Cases:
✔️ Currency Exactness: Proves $50.25/hr converts to exactly 5025 integer cents without precision loss.
✔️ Immutability & copyWith: Verifies state updates clone objects cleanly while preserving unmentioned fields.
✔️ Retainer Null-Clearing: Validates that boolean sentinel flags (clearEndDate: true) safely wipe optional dates to null.
✔️ Anti-Double-Billing Engine: Proves already-billed time IDs are excluded in 
O
(
1
)
O(1)
 time from future invoices.
✔️ Offline Regex Extraction: Verifies email and phone extraction from messy unstructured text signatures when AI is offline.
✔️ Null-Safety Edge Cases: Verifies empty fallback defaults prevent runtime type-cast exceptions.
📂 Project Structure
code
Text
lib/
├── models/                  # Pure immutable domain entities (Client, Project, Invoice, TimeEntry)
├── repositories/            # Abstract contracts & Firebase implementations
├── providers/               # Riverpod dependency injection & reactive streams
│   ├── repositories_provider/
│   ├── stream_provider/
│   └── state_provider/
├── screens/                 # Presentation layer (Directory cockpits & forms)
│   ├── auth/                # Declarative AuthGate & Login/SignUp flows
│   └── ...
└── services/                # Gemini AI Service & Vector PDF compiler

test/
├── models/                  # Unit tests for domain entity arithmetic
└── logic/                   # Algorithmic tests (Anti-double-billing & regex parsing)
🚀 Getting Started
Prerequisites
Flutter SDK (3.x or higher)
Dart SDK (3.x or higher)
Firebase CLI & Configured Google Project
Installation
code
Bash
# 1. Clone the repository
git clone https://github.com/laibanurr/freelancer_business_os.git

# 2. Navigate to project root
cd freelancer_business_os

# 3. Install dependencies
flutter pub get

# 4. Run automated tests
flutter test

# 5. Run the application
flutter run
<div align="center">
<sub>Engineered by <b>Laiba Nur</b> • Specialized in Flutter, Riverpod & Mobile Architecture</sub>
</div>
```