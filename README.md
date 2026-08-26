# GramVault

Every gram, sealed offline. GramVault is a personal food log for people who want calorie and macro tracking that still works when the network is cut. There is no account, no ads, and no remote configuration. Nutrition data is credited to Open Food Facts. This is not medical advice.

## Architecture

VIPER, organised by layer (`Presentation/`, `Domain/`, `Data/`, `Common/`).

Each screen is a module: View, Interactor, Presenter, Entity, Router, plus a `Module` assembler. Communication uses suffix-based protocols (`VaultViewProtocol`, `VaultInteractorInput`, `VaultPresenterOutput`, `VaultRouterProtocol`). Presenters import Foundation only.

VIPER fits this product because search, scan, assign, targets and the sealed catalogue each have distinct write paths and failure states. Isolating those rules in interactors keeps the steel UI from owning persistence or Open Food Facts.

## Unique feature — Sealed vault

Offline-first. Every product resolved from Open Food Facts is cached in Core Data and remains searchable. The **Sealed** toggle on the vault chamber disables the network entirely. Lookups then use the local vault and the bundled shelf only. That is why someone would pick GramVault: the catalogue keeps working after the door is sealed.

Plan horizon: **14 days**. Loose Change (snack) cannot be planned; a future date remaps it to Vault C (Evening).

## How this app differs

- One root vault screen. Everything else is a modal. No push navigation.
- Search and scan share `SourceModal` with a segmented switch.
- Detail and assign are a two-page `AssignWizard`.
- Slots are Vault A / Vault B / Vault C / Loose Change.
- Day keys are `Int` epoch seconds at `startOfDay`.
- Scanner is `VNDetectBarcodesRequest` on the live video buffer with a machined lock lamp.
- No shared code with other 21AUG apps.

## Design

Vault / industrial brushed steel. Palette tokens: `background` `#2C3338`, `surface` `#373E44`, `ink` `#E8ECEF`, `accent` `#FFB300`, `muted` `#8A939A`. DIN Condensed Bold for headers and numerals; system for body. Hard edges, 8 pt spacing.

## Build

```bash
cd App03_GramVault
/Users/belzephyrus/Documents/gambling/21AUG/tools/xcodegen/bin/xcodegen generate
xcodebuild -scheme GramVault -destination 'generic/platform=iOS' build
xcodebuild -scheme GramVault -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Bundle identifier: `com.gramvault.vault`. User-Agent: `GramVault/1.0 (iOS; +https://gramvault.pro)`. Search: `/cgi/search.pl`, `page_size` 24. Demo seed key: `gvt.demo.v1` (simulator only).

## AI art

Style: photorealistic material texture.

Base prompt reused for every asset:

```
4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection
```

Exact prompt per image set:

**gvt_AppIcon** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, the app's single emblem, centred, filling the canvas edge to edge

**gvt_Splash** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a vertical hero composition with a calm, uncluttered centre band

**gvt_Onboarding1** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a person or object representing discovering what is in packaged food

**gvt_Onboarding2** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a scanning or measuring motif showing a product being identified

**gvt_Onboarding3** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a goal or target motif showing daily progress being met

**gvt_EmptyLog** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, an empty vessel, surface or container waiting to be filled

**gvt_EmptySearch** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a search motif that has come back with nothing found

**gvt_EmptyPlan** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, an empty schedule, grid or horizon with nothing scheduled

**gvt_EmptyWish** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, an empty basket, list or shelf

**gvt_SlotVaultA** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a morning motif appropriate to the theme

**gvt_SlotVaultB** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a midday motif appropriate to the theme

**gvt_SlotVaultC** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, an evening motif appropriate to the theme

**gvt_SlotLooseChange** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a small extra or in-between motif appropriate to the theme

**gvt_MacroProtein** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a symbol standing for protein, rendered as a single clear emblem

**gvt_MacroCarbs** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a symbol standing for carbohydrate, rendered as a single clear emblem

**gvt_MacroFat** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a symbol standing for dietary fat, rendered as a single clear emblem

**gvt_ProductPlaceholder** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a generic packaged grocery item with no readable branding

**gvt_CardBackdrop** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, an abstract backdrop suitable for sitting behind a product card

**gvt_Texture** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a seamless repeating surface pattern

**gvt_ControlFace** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, the face of a single physical control such as a dial, key or slider handle

**gvt_ScanOverlay** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a framing reticle or targeting bracket, open in the middle

**gvt_TwistHero** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, an emblem representing this app's signature feature

**gvt_SuccessMark** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a confirmation mark or celebratory emblem

**gvt_HeaderDecor** — 4k material texture, brushed stainless steel, realistic, octane render, industrial machined surface, amber warning light reflection, a wide decorative band or ornament
