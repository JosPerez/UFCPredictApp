# OctAIQ — iOS App

UFC fight prediction app powered by machine learning. Browse fighters, explore events, check rankings, and get AI-powered fight predictions with confidence levels and method breakdowns.

**Platform:** iOS 17.0+
**Language:** Swift 5.9
**UI:** SwiftUI
**Cache:** SwiftData
**Networking:** BlackSpartan (private CocoaPod)

---

## Screenshots

```
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Fighters │ │  Events  │ │ Rankings │ │ Predict  │
│          │ │          │ │          │ │          │
│ Search   │ │ Upcoming │ │ By div   │ │ Select A │
│ Division │ │ Completed│ │ Champion │ │ Select B │
│ Cards    │ │ Featured │ │ Top 15   │ │ Compare  │
│ Ranking  │ │ Location │ │ Gold     │ │ Predict  │
│ Badge    │ │ Stats    │ │ border   │ │ Results  │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

---

## Architecture

```
OctAIQ/
├── App/
│   ├── OctAIQApp.swift              # Entry point + SwiftData container
│   └── ContentView.swift            # TabView (4 tabs)
│
├── Config/
│   ├── Config.swift                 # API base URL + API key
│   ├── BSColors.swift               # Adaptive color system (light/dark)
│   └── ThemeManager.swift           # Theme management
│
├── Models/                          # SwiftData models
│   ├── CachedFighter.swift          # Fighter list cache
│   ├── CachedEvent.swift            # Event list cache
│   ├── CachedRanking.swift          # Rankings cache (compositeKey)
│   └── CachedPrediction.swift       # Prediction history (full model data)
│
├── Views/
│   ├── Fighters/
│   │   ├── FighterListView.swift    # Search + division filter + list
│   │   ├── FighterDetailView.swift  # 3 tabs: Overview / Stats / Fights
│   │   └── FighterPickerView.swift  # Selection modal for predictions
│   │
│   ├── Events/
│   │   ├── EventListView.swift      # Upcoming/Completed toggle + featured
│   │   └── EventDetailView.swift    # Conditional layout by event status
│   │
│   ├── Rankings/
│   │   └── RankingsView.swift       # Division pills + ranked fighters
│   │
│   ├── Prediction/
│   │   ├── PredictionView.swift     # Fighter selection + results (5 sections)
│   │   ├── PredictionHistoryView.swift  # Saved predictions with badges
│   │   └── FactorsGuideSheet.swift  # Explains all prediction factors
│   │
│   └── Components/
│       ├── FighterAvatar.swift      # Circular avatar with fallback initials
│       ├── PerformanceCard.swift     # Radar chart + stat cards
│       └── CollapsibleSection.swift # Expandable section header
│
├── ViewModels/
│   ├── FighterListViewModel.swift
│   ├── FighterDetailViewModel.swift
│   ├── EventListViewModel.swift
│   ├── EventDetailViewModel.swift
│   ├── RankingsViewModel.swift
│   └── PredictionViewModel.swift
│
├── Sync/
│   └── SyncManager.swift            # SwiftData cache management (8-day TTL)
│
└── Navigation/
    └── EventNavigation.swift        # Cross-tab navigation wrapper
```

---

## Tabs

### Tab 0 — Fighters

Search and browse UFC fighters with division filter.

- **List:** Concise cards with name, nickname, record (W green / L red), ranking badge
- **Detail — Overview:** Info grid, win methods bars, PerformanceCard (radar chart + stat cards)
- **Detail — Stats:** Collapsible sections (performance, physical, finish rounds, strike breakdown with style pills)
- **Detail — Fights:** Fight history cards, tap to navigate to event detail

### Tab 1 — Events

Browse upcoming and completed UFC events.

- **Upcoming:** Featured event card with gradient, countdown, fight cards with career comparison + strengths/weaknesses
- **Completed:** Year filter pills, fight cards with full stats bars, market consensus, AI analysis
- **Fight selector:** Horizontal scroll of matchup pills
- **Location** shown on all events

### Tab 2 — Rankings

Current UFC rankings by division.

- Division pills ordered: FLW → BW → FW → LW → WW → MW → LHW → HW → Women's
- Champion card with gold border
- Cached in SwiftData with 30-day TTL
- Tap fighter to navigate to detail

### Tab 3 — Predict

AI-powered fight predictions with multi-model results.

- **Selection:** Red/blue corner pickers with weight class filtering
- **Pre-prediction:** Matchup breakdown (record, stats, style comparison)
- **Results — 5 sections:**
  1. 🏆 Winner prediction (probability bar + confidence badge)
  2. 🏁 Fight outcome (Decision vs Finish)
  3. 🎯 Predicted method (DEC / KO/TKO / SUB cards + segmented bar)
  4. 🕐 Duration forecast (R1-R5 horizontal bar chart)
  5. 📊 Key factors (with info guide sheet)
- **History:** Saved predictions with method/outcome badges, swipe to delete

---

## Data Flow

```
API (Railway)
    ↓ BlackSpartan
ViewModel (fetches + processes)
    ↓ @Observable
View (renders)
    ↓ on success
SwiftData (caches locally)
```

### Caching Strategy

| Data | TTL | Model |
|---|---|---|
| Fighters | 8 days | CachedFighter |
| Events | 8 days | CachedEvent |
| Rankings | 30 days | CachedRanking |
| Predictions | Permanent | CachedPrediction |

---

## SwiftData Models

### CachedFighter

```swift
@Model CachedFighter
├── fighterId: Int (server ID)
├── fullName, firstName, lastName: String
├── nickname, weightClass: String?
├── recordWin, recordLoss, recordDraw: Int
├── imgThumb: String?
├── currentRank: Int?
├── isActive: Bool
└── lastUpdated: Date
```

### CachedPrediction

```swift
@Model CachedPrediction
├── fighterA/BId, fighterA/BName, fighterA/BImg
├── fighterA/BProb: Double
├── confidence, modelUsed: String
├── decisionProb, finishProb: Double?          // Outcome
├── methodDecProb, methodKoProb, methodSubProb  // Method
├── durationR1, R2, R3, Late, Dec: Double?     // Duration
├── createdAt: Date
├── computed: winnerName, predictedMethod, isFinishLikely
```

---

## Design System

### BSColors (adaptive light/dark)

```swift
BSColors.background       // App background
BSColors.surface           // Card background
BSColors.surfaceSecondary  // Nested elements
BSColors.accent            // Red corner / primary actions
BSColors.accentBlue        // Blue corner
BSColors.winGreen          // Wins / HIGH confidence
BSColors.lossRed           // Losses
BSColors.titleGold         // Champion / MEDIUM confidence
BSColors.textPrimary       // Main text
BSColors.textSecondary     // Secondary text
BSColors.textTertiary      // Labels
BSColors.textHint          // Placeholders
BSColors.border            // Dividers
```

### Typography Scale

```
28pt bold    — Screen titles
15pt bold    — Fighter names (detail)
14pt semi    — Card primary text
13pt bold    — Section titles
12pt regular — Body text
11pt medium  — Labels, records
10pt medium  — Corner labels, badges
9pt bold     — Pill text, small badges
8pt medium   — Bar labels, segmented bar text
```

---

## Key Components

### PerformanceCard

Radar chart with 6 axes (Striking, Defense, Grappling, Submissions, Cardio, Power) + stat cards grid. Used in Fighter Detail Overview tab.

### Smart Segmented Bar

Handles small segments gracefully — if a segment is too narrow for text, labels appear below the bar instead. Used in method and duration predictions.

### Event Navigation

Cross-tab navigation using `EventNavigation` hashable wrapper. Fighter's fight history → tap → event detail with preselected fight.

```swift
struct EventNavigation: Hashable {
    let eventId: Int
    let fightId: Int?
}
```

---

## Setup

### Prerequisites

- Xcode 16+
- iOS 17.0+ device or simulator
- BlackSpartan pod (local path)
- Running OctAIQ API backend

### Install

```bash
# Clone
git clone <repo-url>
cd OctAIQ

# Install pods
pod install

# Open workspace
open OctAIQ.xcworkspace
```

### Configure

Edit `Config.swift`:

```swift
struct Config {
    static let baseURL = "https://your-app.up.railway.app"
    static let apiKey = "your-api-key"
}
```

### Run

1. Select target device/simulator (iOS 17+)
2. Build & Run (⌘R)

---

## Backend Dependency

Requires OctAIQ FastAPI backend running with:

- PostgreSQL database populated via ETL pipeline
- 4 ML models deployed (winner pure/market, decision/finish, method, duration)
- API key authentication enabled

See `ufc_predictor/README.md` for backend setup.

---

## License

Private project. Not for distribution.
