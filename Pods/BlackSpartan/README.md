# BlackSpartan

Networking framework for OctAIQ iOS app. Handles API communication, model decoding, and service layer abstraction.

**Type:** CocoaPod (private)
**Language:** Swift 5.9+
**Min iOS:** 17.0

---

## Installation

```ruby
# Podfile
pod 'BlackSpartan', :path => '../BlackSpartan'
```

```bash
cd OctAIQ
pod install
```

---

## Architecture

```
BlackSpartan/
├── Core/
│   ├── BSNetworkManager.swift       # HTTP client (URLSession)
│   ├── BSResponseDelegate.swift     # Delegate protocol for responses
│   ├── BSErrorBase.swift            # Error model
│   └── Config.swift                 # Base URL configuration
│
├── Models/
│   ├── BSFighterProfile.swift       # Fighter detail with stats + style
│   ├── BSEventModel.swift           # BSEventDetail + BSEventFight
│   ├── BSPredictModel.swift         # Prediction + Outcome + Method + Duration
│   ├── BSRankingModel.swift         # Rankings by division
│   ├── BSRecentFight.swift          # Fight history entry
│   ├── BSFightingStyleData.swift    # Strike target/position/grappling/tempo
│   └── BSPerformanceStats.swift     # Career stats (SLpM, defense, etc.)
│
├── Services/
│   ├── BSFighterService.swift       # GET /fighters/, /fighters/{id}/profile
│   ├── BSEventService.swift         # GET /events/, /events/{id}
│   ├── BSRankingService.swift       # GET /rankings/
│   └── BSPredictService.swift       # POST /predict/
│
└── BlackSpartan.podspec
```

---

## Models

### BSFighterProfile

```swift
BSFighterProfile
├── id: Int
├── firstName, lastName, fullName: String
├── nickname: String?
├── weightClass: String?
├── recordWin, recordLoss, recordDraw: Int
├── imgThumb: String?
├── currentElo: Double?
├── currentRank: Int?
├── winRate, finishRate: Double?
├── physical: BSPhysicalStats
│   ├── heightInches, reachInches, legReachInches: Double?
│   └── age: Int?
├── performance: BSPerformanceStats
│   ├── sigStrikesLandedPm, sigStrikesAbsorbedPm: Double?
│   ├── sigStrikeDefensePct, takedownDefensePct: Double?
│   ├── knockdownAvg, submissionAvg, takedownAvg: Double?
│   └── avgFightTimeSecs: Int?
├── fightingStyleData: BSFightingStyleData?
│   ├── strikeTarget: (headPct, bodyPct, legPct)
│   ├── strikePosition: (distancePct, clinchPct, groundPct)
│   ├── grappling: (tdAccuracy, avgCtrlTimeSecs)
│   └── tempo: (r1KdAvg, cardioIndex)
└── recentFights: [BSRecentFight]
    ├── fightId, eventId: Int
    ├── opponentName, opponentImg: String?
    ├── result, method: String
    ├── round: Int, timeSecs: Int?
    ├── sigStrikes, sigStrAttempted, sigStrPct: Int/Double?
    ├── takedowns, subAttempts: Int?
    └── ctrlTimeSecs: Int?
```

### BSEventDetail

```swift
BSEventDetail
├── id: Int
├── name: String
├── eventDate: String
├── location: String?
├── fightCount, titleFights, finishes: Int
├── isUpcoming: Bool
└── fights: [BSEventFight]
    ├── fightId: Int
    ├── method, methodDetail: String?
    ├── round: Int?, timeSecs: Int?
    ├── isTitleFight: Bool
    ├── outcome, weightClass: String
    ├── fighterR/B: id, name, img, record, winner
    ├── fighterR/B stats: kd, sigStr, sigStrAttempted, sigStrPct
    ├── fighterR/B grappling: tdLanded, tdAttempted, subAtt, ctrlSecs
    ├── fighterR/B career: slpm, sapm, strDef, kdAvg, subAvg, tdDef
    └── odds: fighterRProb, fighterBProb, numSources
```

### Prediction

```swift
Prediction
├── fighterAId, fighterBId: Int
├── fighterAName, fighterBName: String
├── fighterAWinProb, fighterBWinProb: Double
├── confidence: String (HIGH/MEDIUM/LOW)
├── modelUsed: String (winner_pure/winner_market)
├── topFactors: [PredictionFactor]
│   ├── feature: String
│   └── impact: Double
├── outcome: OutcomePrediction?
│   ├── decisionProb: Double
│   └── finishProb: Double
├── method: MethodPrediction?
│   ├── decisionProb: Double
│   ├── koTkoProb: Double
│   └── submissionProb: Double
├── duration: BSDurationPrediction?
│   ├── r1FinishProb, r2FinishProb, r3FinishProb: Double
│   ├── lateFinishProb: Double
│   └── decisionProb: Double
└── warning: String?
```

---

## Services

### BSFighterService

```swift
let service = BSFighterService(url: Config.baseURL)
service.delegate = self

// List fighters
service.getFighters(query: "Topuria", weightClass: "Featherweight", limit: 20, offset: 0)

// Fighter profile
service.getFighterProfile(id: 42)
```

### BSEventService

```swift
let service = BSEventService(url: Config.baseURL)
service.delegate = self

// List events
service.getEvents(status: "upcoming", year: 2026, limit: 20)

// Event detail
service.getEventDetail(id: 635)
```

### BSRankingService

```swift
let service = BSRankingService(url: Config.baseURL)
service.delegate = self

// Rankings by division
service.getRankings(weightClass: "Lightweight")
```

### BSPredictService

```swift
let service = BSPredictService(url: Config.baseURL)
service.delegate = self

// Predict fight
let request = PredictionRequest(fighterAId: 18, fighterBId: 554)
service.predictFight(request: request)
```

---

## Delegate Pattern

All services use `BSResponseDelegate`:

```swift
extension MyViewModel: BSResponseDelegate {
    func recievedEntity<T>(entity: T, requestName: String) {
        if let profile = entity as? BSFighterProfile {
            self.profile = profile
        } else if let error = entity as? BSErrorBase {
            self.errorMessage = error.message
        }
    }
}
```

---

## Authentication

All requests include `X-API-Key` header, configured in `Config.swift`:

```swift
struct Config {
    static let baseURL = "https://your-railway-app.up.railway.app"
    static let apiKey = "ufc-predictor-secret-key-2024"
}
```

---

## Dependencies

None. Pure Swift with URLSession.

---

## API Compatibility

Designed for OctAIQ FastAPI backend v2.0:

| Endpoint | Service | Model |
|---|---|---|
| `GET /fighters/` | BSFighterService | [CachedFighter] |
| `GET /fighters/{id}/profile` | BSFighterService | BSFighterProfile |
| `GET /events/` | BSEventService | [BSEvent] |
| `GET /events/{id}` | BSEventService | BSEventDetail |
| `GET /rankings/` | BSRankingService | [BSRanking] |
| `POST /predict/` | BSPredictService | Prediction |
