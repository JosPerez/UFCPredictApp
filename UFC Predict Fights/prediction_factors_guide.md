# OctAIQ — Prediction Factors Guide

When OctAIQ predicts a fight, it shows the top factors that influenced the prediction. Here's what each one means and why it matters.

---

## How to read factors

Each factor shows a **name** and an **impact value**.

- **Positive impact** → favors Fighter A (Red corner)
- **Negative impact** → favors Fighter B (Blue corner)
- **Larger absolute value** → stronger influence on the prediction

---

## Elo & Rankings

### Elo rating (Red/Blue)
A skill rating calculated from fight history. Wins against strong opponents raise Elo more than wins against weak opponents. Ranges from ~1400 (low) to ~1800 (elite). Think of it as a chess rating for fighters.

### Elo advantage
The difference in Elo ratings between both fighters. A +100 Elo advantage is significant — it means one fighter has consistently beaten better opponents.

### Ranking (Red/Blue)
The fighter's current UFC ranking in their division. Champion = 0, #1 contender = 1, up to #15. Unranked fighters default to 99.

### Ranking advantage
The gap in rankings. When a #2 faces a #10, this factor reflects that 8-spot difference.

---

## Market & Odds

### Market odds edge
The difference in betting market probability between both fighters. When the market gives Fighter A a 70% chance and Fighter B 30%, the edge is +0.40. This captures the collective wisdom of bettors and oddsmakers.

### No odds available
A flag indicating this fight has no betting odds data. The model learned that fights without odds (smaller events, less-known fighters) behave differently than fights with full market coverage.

---

## Career Stats

### Experience gap
The difference in total UFC fights. A 20-fight veteran vs a 5-fight newcomer has a +15 experience gap. Experience correlates with octagon IQ and composure.

### Win rate advantage
The difference in career win percentage. A fighter with 85% win rate vs one with 60% shows a +0.25 advantage.

### Finish rate edge
How often each fighter wins by KO/TKO or submission vs going to decision. A high finish rate means the fighter is dangerous and can end fights early.

### KO rate edge
Specifically how often each fighter wins by knockout or TKO. Separates pure strikers from grapplers.

### Submission rate edge
How often each fighter wins by submission. High values indicate elite ground game — think Oliveira, Makhachev.

### Vulnerability to finishes
How often each fighter LOSES by KO or submission. A fighter who gets finished frequently is more likely to lose that way again — a known chin weakness or defensive gap.

### Avg finish round gap
The average round in which each fighter's wins end. Lower = faster finisher. A fighter who typically finishes in R1 is different from one who grinds to R3.

### Knockdown average gap
Career knockdowns landed per fight. Measures pure striking power at the highest level — a KD often leads to a finish.

### Sig. strikes per fight gap
Total significant strikes landed per fight. Measures overall output volume — some fighters throw 100+ strikes while others are patient counter-strikers.

---

## Recent Form

### Recent form (last 3)
Win rate in the last 3 fights. Captures a fighter's current momentum. Going 3-0 recently is very different from 0-3.

### Recent form (last 5)
Same concept but over 5 fights — a slightly longer window that smooths out one-fight anomalies.

### Last fight result
Whether the fighter won (+1) or lost (-1) their most recent fight. Coming off a loss vs coming off a win changes fighter psychology and preparation.

### Win streak advantage
Current consecutive wins or losses. A 10-fight win streak carries more momentum than 1-1. Negative values mean a losing streak.

### Activity gap
Days since each fighter's last fight. Ring rust is real — a fighter returning after 2 years is different from one who fought last month. But too-frequent fighting can mean fatigue.

---

## Physical Attributes

### Height advantage
Height difference in inches. Taller fighters can use range and jab effectively, but shorter fighters can get inside. Context matters — 2 inches is significant at lightweight, less so at heavyweight.

### Reach advantage
Arm reach difference in inches. Longer reach = ability to hit without being hit. One of the most predictive physical features in MMA. A 6-inch reach advantage is massive.

### Leg reach advantage
Leg reach difference. Affects kicking range and ability to maintain distance. Less impactful than arm reach but still meaningful for fighters who use leg kicks.

### Age difference
Age gap between fighters. Younger fighters tend to have better cardio and recovery, while older fighters bring experience. Extreme gaps (10+ years) can be significant.

### Relative reach edge
Reach normalized by weight class. A 72-inch reach means different things at flyweight vs heavyweight. This metric adjusts for that.

---

## Striking

### Striking volume edge
Significant strikes landed per minute. Measures how active and aggressive a fighter is on the feet. Higher volume fighters control distance and accumulate damage.

### Damage absorbed gap
Significant strikes absorbed per minute. Fighters who absorb a lot of damage are more likely to get finished. Low absorption means good defense or evasiveness.

### Strike defense edge
Percentage of incoming strikes that are evaded or blocked. Elite defenders (>60%) are hard to hit cleanly. Poor defenders (<40%) get tagged frequently.

### KO power advantage
Career knockdown average — measures raw stopping power. Fighters with high KD averages carry danger in every exchange.

---

## Grappling

### Submission threat edge
Average submission attempts per 15 minutes. High values (>1.5) indicate a fighter who actively hunts for submissions on the ground. Changes how opponents approach the grappling exchanges.

### Takedown defense edge
Percentage of takedown attempts successfully defended. Elite TD defense (>80%) means the fighter can keep it standing. Poor TD defense (<50%) means they'll likely end up on the ground against a wrestler.

### Takedown accuracy edge
Percentage of takedowns successfully completed. A wrestler with 60%+ TD accuracy will likely get the fight where they want it.

### Control time advantage
Average seconds of ground control per fight. Dominant grapplers accumulate 5+ minutes of control. This wins rounds and exhausts opponents. Fighters like Belal Muhammad and Khabib Nurmagomedov excel here.

---

## Fighting Style

### Head targeting edge
Percentage of strikes aimed at the head. Head hunters (>55%) have more KO potential but are more predictable. Body/leg fighters are more diverse but finish less.

### Distance fighting edge
Percentage of strikes thrown at distance vs clinch/ground. Distance fighters (>70%) prefer to keep it standing and use footwork. Low values suggest a clinch-heavy or ground-and-pound style.

### Round 1 aggression
Average knockdowns in Round 1. Measures how dangerous a fighter is early. Fast starters with high R1 KD averages often win by early finish — but may fade if the fight goes long.

### Cardio advantage
Ratio of striking output in rounds 3+ compared to rounds 1-2. Values above 0.8 mean the fighter maintains volume late — "cardio machines" like Max Holloway. Values below 0.3 suggest the fighter fades significantly.

---

## Data Flags

### Missing physical data
Indicates that height/reach/age data is not available for this fighter. The model treats missing data differently from zero — it learned that fighters without physical data in the system (usually newcomers) have different outcomes.

### Missing career stats
Indicates that career performance stats (SLpM, defense %, etc.) are not available. Usually means the fighter is new to the UFC or the data wasn't captured.

### Unranked
Indicates the fighter is not in the current top 15 of their division. Unranked fighters in ranked fights tend to be underdogs, and the model captures this pattern.

---

## Tips for interpretation

1. **Multiple factors matter more than one** — A fighter with reach advantage, better defense, AND higher Elo is a strong pick. One factor alone is weak.

2. **Context matters** — "Takedown defense edge" matters more when the opponent is a wrestler. "KO power advantage" matters more when the opponent has poor chin.

3. **Confidence level** — LOW confidence means the factors are close and the fight is a toss-up. HIGH confidence means multiple factors strongly favor one side.

4. **The model doesn't know everything** — Injuries, weight cuts, camp changes, mental state, and fight-week news are NOT captured. Use the prediction as one input, not the only one.
