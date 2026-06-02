# Bloodcorp Game Design

This document is the source of truth for Bloodcorp's broad game design: player fantasy, core loop, roster philosophy, progression direction, sponsor pressure, economy, tone, and major design decisions. Use `docs/COMBAT_DESIGN.md` for detailed battle mechanics and `docs/TASKS.md` for the active backlog.

## Core Fantasy

Bloodcorp is a dystopian gladiator manager game with cyberpunk/WH40k aesthetics. The player runs a stable of disposable-but-valuable gladiators inside a corporate bloodsport economy where sponsors, spectacle, and survival are always in tension.

The player is not only a battlefield commander. They are the owner/manager making recruitment, deployment, upgrade, sponsor, and risk decisions between fights. Battles should feel brutal and tactical; the campaign layer should make every fighter, credit, and sponsor condition matter.

## Design Pillars

- **Corporate bloodsport spectacle:** The arena is a product. Sponsors reward violence, style, obedience, and marketable outcomes.
- **Compact tactical choices:** Battles should be readable, fast, and positional, with each turn offering meaningful movement, action, and bonus-action decisions.
- **Roster as churning asset pool:** Gladiators are individually meaningful but the system expects turnover. They become distinct through stats, skills, rank, equipment, injuries, traits, and augmentations, while always being at risk and always being replaced.
- **Sponsor pressure:** Contracts should tempt the player to fight suboptimally for rewards, penalties, style, or future opportunity.
- **Management consequence:** Hiring, firing, upgrades, facilities, equipment, and augments should shape what happens in the arena.
- **Readable pixel brutality:** The presentation should stay dark, neon, isometric, pixel-art, and clear enough that tactical state is easy to scan.

## Roster Philosophy: Churn, Not Permanence

Bloodcorp is **churn-focused**, not a persistent-team RPG. The player should never feel they are building one irreplaceable hero over hundreds of fights. Instead they run a pipeline: draft prospects, develop the ones who pan out, ride them through their prime, and discard them when they are spent.

This commitment resolves the central design tension and constrains everything downstream:

- **Per-gladiator investment is moderate, not deep.** A gladiator is defined by stats + a recognizable skill + rank + a couple of equipment/augment slots. No sprawling build trees that take 30 minutes to plan. The depth lives in the *roster-level* decisions, not in any single fighter.
- **Death is rare; injury is common.** Losing a fighter to a single bad d20 roll is a feel-bad in a game with investment. Combat variance should produce setbacks (injuries, recoverable in the med bay), not catastrophes. Death is reserved for genuinely losing a fight badly, or for deliberate high-risk gambles. See `COMBAT_DESIGN.md` "Casualty Resolution".
- **Pressure comes from economy and sponsors, not from save-scumming around permadeath.** The player should be making informed gambles on appreciating/depreciating human assets, not reloading to dodge RNG.

### Variance Principle

The game stacks several layers of randomness: hidden potential, hidden peak timing, d20 combat rolls, casualty/injury rolls, and the recruit pool. Each layer is acceptable alone, but together they can make the player feel they control nothing. **Rule: every RNG layer must be paired with a player decision.** Hidden potential is paired with the draft and scouting choice; combat dice are paired with positioning and action economy; the casualty roll is paired with deploy/retreat and contract-risk choices. If a random system has no decision attached, cut it or wrap it in one.

## Roster Lifecycle & Development Arc

Inspired by Arena's age-based careers (fighters start young, peak, decline, and retire) and Football Manager's hidden current-ability/potential model. The clock is **Service**, not age.

### The Service Clock

- A gladiator accumulates **Service** measured in **matches fought**.
- Matches are grouped into **Seasons** (a Season = a fixed block of matches tied to the division structure; first-pass: 5 matches per Season).
- The arc is expressed in matches/Seasons, never in literal years.
- First-pass career length: roughly **15–30 matches**, with the prime window somewhere in the middle. Careers must be short enough that a player on a casual cadence sees a full arc within a handful of sessions.

### Career Stages

A gladiator moves through hidden, arc-driven stages. The *stage label* can be shown to the player (or kept fuzzy); the *exact transition timing* is hidden.

1. **Prospect** — early Service, below potential, growing.
2. **Rising** — rapid growth toward the Ceiling.
3. **Prime** — at or near the Ceiling; best performance window and peak market value.
4. **Decline** — stat erosion and/or rising injury susceptibility.
5. **Spent** — past usefulness; the corp discards the asset (see Decline Decisions).

### Hidden Ceiling, Visible Growth, Fuzzy Projection

This is the heart of the mechanic. **Hidden does not mean invisible.**

- **Ceiling (hidden):** the true potential cap. Never shown as an exact number.
- **Growth (visible):** after each match (or each Season tick), a gladiator receives a development tick that rolls stat increases drawn from hidden ranges governed by the Ceiling and current stage. The player *sees the stat numbers go up* — the reveal fantasy ("my cheap rookie became a monster") depends on watching growth happen.
- **Projection (fuzzy, visible):** a corporate-analytics estimate of the gladiator's potential, shown as a band or grade rather than an exact value. This is the player's agency lever — it lets them make an *informed gamble* at the draft instead of a blind one.
- **Scouting sharpens the Projection.** Investing credits / a facility (comms suite) narrows the Projection band and may reveal a trait. Scouting is how the player buys down uncertainty.

### Loose Correlation, Not Full Decoupling

Starting stats correlate **loosely** with the hidden Ceiling: a high-stat, expensive recruit is *probably* good, but both busts (high stats, low Ceiling) and steals (low stats, high Ceiling) are possible. Full decoupling would make the recruit market's prices meaningless and remove all read; loose correlation preserves a skill ceiling for the player.

### Traits as Tells

Traits hint at the shape of the arc and give scouting something to reveal. Some are visible at recruitment, some only after scouting. Examples (data-driven, expandable):

- **Prodigy** — high Ceiling, early peak.
- **Late Bloomer** — slow start, peak comes later.
- **Workhorse** — modest Ceiling, long Prime.
- **Journeyman** — low Ceiling, reliable, cheap.
- **Glass** — high injury susceptibility.
- **Burnout** — short Prime, fast Decline.

### Decline Decisions

A declining or Spent gladiator must come with a **player action**, never just a sad downward slope. Corporate framing makes this clean: a fading fighter is a liability the corp liquidates.

- **Retire for salvage:** a credit payout (cyberware/parts reclaimed — thematic).
- **Last contract:** deploy to a high-risk/high-reward sponsor contract; death is likely, but the payout is large.
- **Trainer role:** assign to the training room facility to boost prospects' development, converting the veteran's experience into roster value.

## Core Loop

The current playable loop is:

`Menu -> Management -> SponsorSelect -> Battle -> Result -> Management`

Each cycle should create a small management problem:

1. Review roster, credits, recruits, and each gladiator's stage/Projection.
2. Invest in gladiators, scouting, gear, augments, or facilities.
3. Choose a sponsor contract with clear rewards, risks, and battle objectives.
4. Fight a compact tactical arena battle.
5. Resolve casualties (injury/death), development ticks, rewards, penalties, sponsor outcomes, and campaign progress.
6. Return to management with new pressure, new prospects, and aging assets.

## Management Layer

Management is where the player shapes the stable before entering the arena. The current foundation supports roster management, random recruit pools, hire/fire decisions, credits, and deployment to sponsor selection.

Future management systems should favor decisions that change battle identity and feed the churn loop:

- **Recruiting / drafting:** Recruits differ by stats, skills, cost, traits, and hidden Ceiling. The draft is the primary gamble.
- **Scouting:** Spend to narrow Projection and reveal traits before committing credits to a recruit.
- **Ranks:** Recruit / veteran / champion tiers affect proficiency, stat progression, cost, and campaign value (see `COMBAT_DESIGN.md`).
- **Equipment:** Weapons and armor grant active or passive combat options, not only bigger numbers.
- **Augmentations:** Cyberware creates unusual tactical abilities, sponsor appeal, and risk/reward tradeoffs, often INT-driven.
- **Facilities:** Training room (boosts development / hosts trainers), med bay (heals injuries), comms suite (scouting / better recruits).
- **Med bay & injuries:** Recover injured gladiators over time or instantly for credits.

## Sponsor Layer

Sponsors are the bridge between management, spectacle, and battle objectives. They should make the player ask: "Can I win, and can I win in the way this sponsor wants?"

Current sponsor contracts include objectives such as kill count, style/round limits, and priority targets. Rewards and penalties resolve after battle.

Future sponsor design should emphasize:

- Clear objective text before battle and visible progress during it.
- Rewards and penalties that matter to management.
- Objectives that create tension with safe tactical play.
- Sponsor identities that imply different values, tone, and preferred violence.
- "Last contract" style high-risk offers that pair with the Decline Decisions above.

## Economy

The economy is the spine of progression. A gladiator is an **appreciating-then-depreciating asset**: cheap and uncertain as a Prospect, most valuable in Prime, worth only salvage when Spent. The corp trades human assets on this curve.

First-pass economic loop (all numbers provisional, pending a dedicated balance pass — see `TASKS.md`):

- **Hire cost:** paid once at draft; loosely scales with visible stats and Projection.
- **Upkeep:** per-match salary; rises as the gladiator ranks up and enters Prime (good fighters are expensive to keep).
- **Contract payout:** scales with division and sponsor; higher divisions pay more but field tougher enemies.
- **Salvage value:** declines with Service; retiring late yields little.
- **Sinks:** scouting, med bay, equipment, augments, facilities.

### Loss Conditions

- **Insolvency:** credits drop below what's needed to pay upkeep / field a roster → game over.
- **Reputation collapse (later):** repeated sponsor failures drive away sponsors until none remain → game over.

### Win / End State

No single victory screen. The long game is reaching and holding the top division (BLOODCORP PRIME) and a legacy/high-score record of the stable's run.

## Tone And Presentation

Bloodcorp should feel harsh, readable, neon, and exploitative. The game is about people turned into assets, sold as entertainment, and pushed into tactical violence by corporate incentives. The development-arc and salvage systems are where this theme bites hardest: the player is literally managing the appreciation and disposal of human beings.

Visual direction:

- Dark background: `#0a0a0f`
- Neon red accent: `#ff2244`
- Cyber cyan for augments: `#00ffcc`
- Amber warnings: `#ffaa00`
- Pixel art sprites
- CRT scanline effect
- Isometric battle perspective

UI should be functional and punchy. Management screens can be dense but must stay scannable. Battle UI should prioritize active unit state, available actions, sponsor progress, and combat readability.

## Combat Design Relationship

This document owns high-level combat intent: compact tactical arenas, violent spectacle, cRPG-style choices, sponsor pressure, churn, and the injury-over-death philosophy.

`docs/COMBAT_DESIGN.md` owns detailed combat mechanics: arena grid behavior, turn structure, movement rules, attack resolution, skill behavior, equipment combat rules, casualty resolution, and near-term combat implementation targets.

When combat changes alter the broader game fantasy, sponsor model, progression direction, or management consequences, update both documents. When combat changes are only mechanical details, update `docs/COMBAT_DESIGN.md` only.

## Design Decision Log

Use this section for major decisions that future agents should not accidentally relitigate.

- **2026-06-02:** `docs/GAME_DESIGN.md` becomes the broad game-design source of truth. `CLAUDE.md` remains the shared agent/workflow guide, `docs/COMBAT_DESIGN.md` remains the combat-specific guide, and `docs/TASKS.md` remains the backlog.
- **2026-06-02:** Project target is a **Steam release** on a casual development cadence (a few hours per week, AI-assisted). Scope decisions favor a coherent shippable core over a maximalist feature set.
- **2026-06-02:** Roster direction locked to **churn-focused**, not a deep persistent team. Per-gladiator investment is moderate; depth lives at the roster level.
- **2026-06-02:** **Death is rare, injury is common.** Combat variance produces recoverable injuries via the med bay; death is reserved for badly lost fights and deliberate high-risk gambles.
- **2026-06-02:** Gladiators have a **hidden development arc** (Football-Manager-style): a hidden Ceiling and hidden peak timing, surfaced to the player as **visible growth** plus a **fuzzy Projection** that scouting sharpens. Starting stats correlate *loosely* (not fully) with the Ceiling.
- **2026-06-02:** Career clock is **Service** (matches fought), grouped into **Seasons** — not literal age. Career stages: Prospect → Rising → Prime → Decline → Spent. First-pass career length ~15–30 matches.
- **2026-06-02:** Decline must carry a **player decision** (retire for salvage / last contract / trainer role), never a passive downward slope.
- **2026-06-02:** **Variance Principle** adopted: every RNG layer must be paired with a player decision.
- **2026-06-02:** Development arc first-pass constants (peak range 10–18, growth chances 0.50/0.70 by stage, decline erosion 0.35, ceiling bias `stat + randi_range(-2,6)`) live in `scripts/DevelopmentData.gd`. All numbers are explicitly provisional and isolated for playtest tuning without touching logic.

## Agent Maintenance Rules

Update this document when work changes major player-facing design, including:

- Core loop or campaign structure.
- Management systems, economy, facilities, roster structure, or progression.
- The roster lifecycle / development-arc model.
- Sponsor contract model, reward/penalty philosophy, or sponsor identities.
- Tone, world direction, visual identity, or UI philosophy.
- Long-term design commitments that future agents should rely on.

Do not update this document for narrow bug fixes, internal refactors, code cleanup, or implementation details unless they change intended player-facing behavior.