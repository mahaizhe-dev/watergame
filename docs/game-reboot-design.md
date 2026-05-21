# Game Reboot Design

## 1. Current Prototype Review

The current codebase already proves three useful things:

- The project can render a playable water-sort loop.
- The team wants a strong "Cyber Chongqing" identity instead of a generic puzzle skin.
- Audio/UI polish matters as much as raw puzzle logic.

The current prototype is not a good foundation for a production mobile game because:

- `scripts/main.lua` mixes boot, routing, puzzle rules, level data, audio, HUD, and rendering.
- Levels are handwritten inline, which makes expansion and tooling difficult.
- The visual style is closer to hard neon sci-fi than cute, mass-market casual.
- Layout and controls read like a desktop prototype, not a thumb-first portrait game.

Conclusion: keep the intent, discard the structure.

## 2. Product Direction

### Positioning

- Platform: mobile-first, portrait casual puzzle game.
- Core loop: classic water-sort puzzle with short sessions and clear one-thumb interaction.
- Experience goal: "easy to start, satisfying to solve, charming enough to keep collecting."

### Creative Direction

- Style keywords: cute, glossy, soft neon, light sci-fi, humid night city, playful Chongqing.
- Tone: not grim cyberpunk; more "future snack street above the clouds."
- World framing: each chapter is a district of a stylized cyber Chongqing, and each level helps restore color flow, power, transit, or signage to that district.

### Visual Pillars

- Q-style silhouettes and rounded shapes.
- Warm fog + neon instead of black-only hacker contrast.
- Local flavor through signs, hillside layering, cable cars, snack stalls, river bridges, stacked streets.
- Liquids should feel toy-like, juicy, and collectible.

## 3. Mobile UX Principles

### Session Design

- Expected session: 1 to 3 minutes.
- First input should happen within 5 seconds after entering a level.
- Restart and undo must stay within thumb range.

### Board Interaction

- Portrait layout.
- Cup/tube tap targets should be generous and visually lifted from the board.
- Selection state must be obvious before pour state is triggered.
- Illegal moves should feel informative, not punitive.

### Accessibility

- Color sets must avoid low-contrast pairs.
- Top-color indicators and subtle icon patterns should support color distinction later.
- Motion needs a reduced-intensity mode.

## 4. UI Design System

### Layout Model

Top area:

- chapter name
- level number
- optional meta progress

Center area:

- puzzle board
- animated backdrop layers with low visual noise

Bottom area:

- undo
- restart
- hint
- booster tray

### UI Shape Language

- Large rounded cards.
- Capsules instead of sharp holo panels.
- Layered acrylic surfaces with soft inner glow.
- Buttons should feel toy-like and pressable, not terminal-like.

### Color Direction

- Base night: deep ink blue, graphite plum.
- Accent cool: aqua neon, mist cyan.
- Accent warm: mango amber, coral pink.
- Support: jade mint, lantern red, cable violet.

Recommended role balance:

- 70% calm dark surfaces
- 20% soft neon accents
- 10% warm celebratory highlights

### Typography

- Chinese UI font should feel rounded and friendly.
- Large numerals for level IDs and move counts.
- Avoid overly thin techno fonts for core gameplay UI.

### Motion

- Fast tap feedback: 80 to 140 ms.
- Pour arcs should be smooth and readable.
- Success states should use short bursts, not long cinematic pauses.

## 5. Gameplay Expansion Strategy

### Base Rule

- Keep the classic water-sort rule set as the foundation.

### Expansion Axes

1. Vessel mechanics
- locked tubes
- cracked tubes
- one-way tubes
- split-output tubes

2. Liquid mechanics
- temperature-sensitive colors
- foam layers
- sticky sludge
- glowing catalyst liquid

3. Board mechanics
- conveyors
- elevators
- blockers
- timed hazards

4. Objective mechanics
- finish within move budget
- rescue a target color
- activate district devices
- clear contamination

### Expansion Rule

Every new mechanic must satisfy:

- readable in under one sentence
- combinable with classic sort logic
- data-driven, not hardcoded into one screen script

## 6. Screen Set

### Home

- district backdrop
- large "Start" button
- current chapter card
- daily event entry
- cosmetic/theme preview

### Level Select

- chapter map as stacked hillside districts
- nodes arranged vertically for portrait scrolling
- each chapter has a strong landmark silhouette

### Puzzle

- compact top HUD
- board centered with breathing room
- bottom action bar inside thumb zone
- pause/settings in top corner only

### Meta Layer

- district restoration progress
- unlockable cup skins, pour effects, sticker badges
- future-ready but optional for MVP

## 7. Technical Direction

### Architecture Goals

- no gameplay data inside screen scripts
- no rendering rules inside state mutation code
- all mechanics described by declarative content tables

### Suggested Layers

1. `config`
- product constants
- screen metrics
- economy and progression defaults

2. `core`
- app shell
- router
- state store
- event bus

3. `gameplay`
- puzzle rules
- move validation
- mechanic resolvers
- simulation helpers

4. `data`
- level schema
- chapter schema
- mechanic metadata

5. `ui`
- theme tokens
- shared widgets
- screen composition

### Content Format

Levels should be pure data:

- tube count
- capacity
- starting stacks
- mechanic placements
- win conditions
- tutorial tags

This makes it possible to build many levels, chapters, and seasonal variations later.

## 8. MVP Scope For The Reboot

### Must Have

- portrait game shell
- one polished puzzle screen
- data-driven level loading
- clean undo/restart/hint loop
- new casual cyber-Chongqing UI kit

### Should Have

- chapter select
- star rating
- district-themed chapter wrapper
- lightweight progression

### Later

- boosters
- skins
- daily challenges
- advanced mechanics
- event chapters

## 9. Build Order

1. Establish the new design tokens and app architecture.
2. Build the new portrait puzzle screen shell.
3. Extract puzzle rules into isolated gameplay modules.
4. Convert levels into schema-driven data.
5. Rebuild home and chapter select around the new tone.
6. Add advanced mechanics only after the base loop feels excellent.

## 10. Working Decision

From this point on, the legacy prototype should be treated as reference only.
All new implementation work should happen inside a separate reboot structure.
