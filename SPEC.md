# Speedwell — Build Specification

> Portfolio app 76, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Pour one cocktail from the bottles on your rail.

| Field | Value |
| --- | --- |
| Product name | Speedwell |
| Bundle identifier | `com.speedwell.rail` |
| Domain | https://speedwell-rail.pro |
| Contact URL | https://speedwell-rail.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `spw_` |
| User-Agent | `Speedwell/1.0 (iOS; +https://speedwell-rail.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Speedwell -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A home bartender taps Pour on tonight's well and gets one cocktail whose bottles already sit on the rail.

### 2.1 User flow

1. Tap Pour on the well and get one cocktail the seated bottles can make
2. Read that recipe on the well and mark it a favorite if you will make it again
3. Open Bar and crack another owned bottle onto the rail, or recork one to lift it off
4. Open Discover to see which recipes still miss a seated bottle, then add that bottle to the bar
5. Open Favorites to browse pinned recipes, or Settings to reset the well
6. Ask Siri or open a deep link to fire Pour or to land on Bar, Discover, Favorites or Settings

### 2.2 Essential behaviour

- Surprise samples only recipes whose required bottles are all Seated on the Rail
- Bundled local recipe catalog; no Open Food Facts, no meal slots, no delivery
- Bar holds Bottles as Backbar or Seated; Crack writes a CrackMark; Recork returns Backbar
- Pour writes a PourMark and does not empty the bottle; empty Rail writes Dry and stays tappable
- Favorites pin recipes; Discover lists makeable recipes versus missing bottles
- App Intents and deep links open Surprise, Bar, Discover, Favorites, Settings or fire Pour
- Simulator seed seats several bottles so Pour is live; leftover scanner and search endpoint unused

---

## 3. Uniqueness assignment for Speedwell

| Axis | Assigned value |
| --- | --- |
| Architecture | **Rail ADT fold (Backbar | Seated); the well is a fold over Bottles; Crack writes a CrackMark and seats the bottle on the Rail; Surprise samples recipes whose bottles are all Seated; Recork returns Seated to Backbar; Pour writes a PourMark and does not empty the bottle; empty Rail writes Dry** |
| UI approach | **SwiftUI pure · take cocktailbar** |
| Naming convention | **Barback / service-well lexicon** |
| File organization | **By well role (Well, Bottle, Rail, Recipe, PourMark, CrackMark)** |
| Dependency strategy | **None** |
| Design direction | **Raspberry energetic** |
| Typography | **SF Pro** |
| Navigation pattern | **Well-link chrome (Surprise holds the well; pour fuses on Surprise; Bar, Discover, Favorites and Settings arrive as sheets; App Intents and URLs route into those sheets or onto Pour)** |
| AI art style | **3D glass render glassmorphism · take cocktailbar** |
| Functional twist | **Crack-then-pour (a bottle is Backbar until Crack seats it on the Rail; Surprise samples only recipes whose bottles all sit on the Rail; Recork lifts a bottle off; Pour writes a PourMark and does not empty the bottle)** |
| Persistence | **UserDefaults+Codable** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — cocktail_bar

**Core** — A home bartender taps Pour on tonight's well and gets one cocktail whose bottles already sit on the rail.

**Audience** — Home bartenders who own bottles and want one drink they can mix tonight, not a recipe browser and not a shopping list.

**User flow**

1. Tap Pour on the well and get one cocktail the seated bottles can make
2. Read that recipe on the well and mark it a favorite if you will make it again
3. Open Bar and crack another owned bottle onto the rail, or recork one to lift it off
4. Open Discover to see which recipes still miss a seated bottle, then add that bottle to the bar
5. Open Favorites to browse pinned recipes, or Settings to reset the well
6. Ask Siri or open a deep link to fire Pour or to land on Bar, Discover, Favorites or Settings

**Essential features**

- Surprise samples only recipes whose required bottles are all Seated on the Rail
- Bundled local recipe catalog; no Open Food Facts, no meal slots, no delivery
- Bar holds Bottles as Backbar or Seated; Crack writes a CrackMark; Recork returns Backbar
- Pour writes a PourMark and does not empty the bottle; empty Rail writes Dry and stays tappable
- Favorites pin recipes; Discover lists makeable recipes versus missing bottles
- App Intents and deep links open Surprise, Bar, Discover, Favorites, Settings or fire Pour
- Simulator seed seats several bottles so Pour is live; leftover scanner and search endpoint unused

**Twist** — Crack-then-pour. Home is the well. Adding a bottle writes Backbar — owned, still sealed; Surprise ignores it. Crack seats it on the Rail and writes a CrackMark. Pour samples one recipe whose every required bottle currently sits on the Rail, writes a PourMark, and leaves the bottles seated. Recork lifts a bottle back to Backbar and Surprise immediately drops any recipe that needed it. Pour on an empty Rail still runs and writes Dry. Seed seats several bottles so Pour is live after first launch. Home verb: pour-the-well, not dice-the-catalog. Discover counts makeable recipes and CrackMarks, not a shopping list.

**Why this is not a repeat** — This is the first cocktail_bar in the portfolio. Home is tonight's well: Pour samples one bundled recipe whose bottles all sit on the Rail, not a dice button over the whole catalog, not recipe_cook's numbered steps, not catalog_crate's rate-and-shelf loop, not Klerion's urn of typed lots, not Nailbally's name wheel, and not Stallage hopping tagged belongings. Owned stock is Backbar until Crack seats it; Recork lifts it; Pour does not empty a bottle and does not read Open Food Facts. Discover, Bar, Favorites and Settings are deep-linked sheets; Surprise never leaves. Scanner and cgi search.pl stay unused leftovers. After seed the rail already holds bottles so Pour is live.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Surprise from what you own. Bar is inventory.
- Invariant: Surprise filters recipes by owned bottles. random.php without stock is a failed verb.
- Never: No delivery. Local bar only.
- Desk `cellar_window`: tempFactor=(cellarC−13)*0.5 yr; young/approaching/ready/holding/pastPeak from vintage+peak window.
- Taste DNA is section 7.6. Do not invent a second look.

### 3.1 Architecture contract

A Bottle is a closed algebraic fold with cases Backbar and Seated; a third role is a defect. The Well is a fold over Bottles: adding a bottle writes Backbar, owned and still sealed; Crack writes a CrackMark, seats the bottle on the Rail, and yields Seated; Recork returns Seated to Backbar. Surprise samples one bundled Recipe whose every required bottle currently sits Seated; it never samples the full catalog and never samples Backbar-only stock. Pour writes a PourMark, leaves bottles Seated, and does not empty them; Pour on an empty Rail still runs and writes Dry. One observable WellStore pattern-matches the fold; Views call crack, recork, and pourWell and never keep a second stock enum. Unit-test seated-only sampling, Recork dropping recipes, PourMark without emptying, and Dry on an empty Rail.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

100% SwiftUI, Light. No UIViewRepresentable, no WKWebView, no Safari sheet, no camera preview. The ui axis restates SwiftUI pure with take-token cocktailbar: first of this family, so compose an original service well, not a recipe browser with a dice control. Do not copy holder file trees, type names, or layouts. Home is the mechanic: Surprise is tonight's well filling remaining height and the iPad width; Pour fuses on that well. Confine custom drawing to that one well hero (Shape, Path, one tinted-glass Material on the energy band); Bar, Discover, Favorites, and Settings are stock sheets (List, Form). Primary Pour is a filled capsule ButtonStyle with default, pressed, disabled, and loading; Recork is not the destructive variant; resetAllData is. Chrome lives inside the label with contentShape, min 44pt. Empty Surprise and empty Bar are full pages (frame maxHeight infinity) with generated cutout art, one headline, one line, and a bottom full-width CTA. Energy band once on Surprise; thick border on Pour only; sheet rows stay quiet. One spring on a successful Pour or Crack; Reduce Motion fades. The ui axis string is never a section title.

### 3.3 Naming contract

Convention: Barback / service-well lexicon.

Examples to follow: `CrackMark`, `PourMark`, `pourWell()`, `Recork`

### 3.4 Dependency contract

None. Zero SPM packages; project.yml has no packages key. No CocoaPods, no bundled font (SF Pro is the system face), no URLSession catalog, no Open Food Facts, no Alamofire. The leftover AVCaptureMetadataOutput scanner and cgi search pl endpoint stay unused; do not import AVFoundation or Vision for capture, do not request a camera permission, and do not call a remote catalog. Foundation and SwiftUI only. Recipes load from a bundled local catalog on device.

### 3.5 Navigation contract

Well-link chrome: Surprise is the root well and never leaves. There is no TabView and no pushed recipe detail. Pour fuses on Surprise. Bar, Discover, Favorites, and Settings arrive as sheets over the well. App Intents open Surprise, Bar, Discover, Favorites, or Settings, or fire Pour in place. Custom URL scheme speedwell routes speedwell://surprise, speedwell://pour, speedwell://bar, speedwell://discover, speedwell://favorites, and speedwell://settings into those same jobs. One haptic on a successful Pour, Crack, or Recork, none on presenting a sheet. Contact URL https://speedwell-rail.pro/contact-us lives on Settings. After onboarding, read ProcessInfo.processInfo.arguments once: -ReviewScreen today stays on Surprise, log presents Bar, goals presents Settings. Skip onboarding on Simulator after the spw.demo.v1 seed so the hook can fire.

### 3.6 Screen composition contract

Deep link routed screens · rail. Physical screens: Surprise (root well; ReviewScreen today), Bar (owned bottles, Crack and Recork; ReviewScreen log), Discover (makeable recipes versus missing seated bottles), Favorites (pinned recipes), Settings (reset the well, catalog credit, contact URL; ReviewScreen goals). Pour fuses on Surprise and is not a destination. Recipe copy is read on the well. Onboarding is a one-shot cover of three pages with Continue or Next at the bottom full width. Empty Surprise with no bottles is a full page: The bar is empty. Add a bottle, then pour. Seeded Surprise seats several bottles so Pour samples a recipe; Dry is a test fixture, not the first frame. No Today, Scan, Search, or Goals screens. ReviewScreen today, log, and goals must open three different screens.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

---

## 4. Target file organization

Scheme: **By well role (Well, Bottle, Rail, Recipe, PourMark, CrackMark)**

```
Speedwell/
  Well/
  Well.swift
  WellStore.swift
  SurpriseView.swift
  WellLinks.swift
Bottle/
  Bottle.swift
  BarView.swift
Rail/
  Rail.swift
  RailSeat.swift
Recipe/
  Recipe.swift
  RecipeCatalog.swift
  DiscoverView.swift
  FavoritesView.swift
PourMark/
  PourMark.swift
CrackMark/
  CrackMark.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Discover
A first-class screen for **Discover**. Must render empty, populated and error states.

### 5.3 Surprise
A first-class screen for **Surprise**. Must render empty, populated and error states.

### 5.4 Bar
A first-class screen for **Bar**. Must render empty, populated and error states.

### 5.5 Favorites
A first-class screen for **Favorites**. Must render empty, populated and error states.

### 5.6 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.7 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.8 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Recipe** — named per this app's convention.
- **Bottle** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **Raspberry energetic**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#F5FAF8` | Screen background |
| `surface` | `#FDFEFE` | Cards, rows, sheets |
| `ink` | `#183931` | Primary text and icons |
| `accent` | `#2CBA96` | Primary action, key figure, progress fill |
| `muted` | `#597870` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro**

SF Pro via Font.system as the energetic type move: heavyweight short verbs, thick, no timid title-on-large-body pair. Display is Pour, Crack, Recork, and the recipe name on the well band (short, 1 or 2 lines, never above 34pt). Body is bottle names on the rail at about 17pt. Caption is Backbar versus Seated. At most six named steps behind one accessor; weights carry hierarchy. Skip a third display size. No Font.custom, no fixedSize, never below 12pt. Tabular figures for makeable counts, CrackMarks, and PourMarks through NumberFormatter. Dynamic Type; at AX5 the well verb may drop a step so it never clips; recipe names truncate, counts win. Day edges use Calendar.current.startOfDay then fold to Int YYYYMMDD.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **16pt** for cards, sheets and primary surfaces; **10pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI pure · take cocktailbar**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI pure · take cocktailbar** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.6 Taste DNA

Aesthetic: **brutal** (Brutal / tactical: visible structure, thick rules, hard contrast.)

Reference system: **energetic** — steal rhythm and restraint, not their colours or logos.

Mood: **punchy**.

Home rhythm (`color-band`, comfortable): Color band, heavy type, a thick rule. Then a dense list.

Energy band once per home. Thick borders on the primary only. Secondary rows stay quiet so the band can shout.

Type move: Heavyweight short verbs, thick, no timid 2xl-on-lg.

Motion (`spring`): One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring.

Voice (`tactical`): Status-first. Noun plus state. 'Scan failed. Try again.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable**

One Codable WellDocument (schemaVersion from 1, Bottles with Backbar or Seated role, CrackMarks, PourMarks including Dry, pinned recipe ids, daykeys as Int YYYYMMDD) encoded to JSON Data in UserDefaults under spw.store.v1. The bundled recipe catalog is read-only in the app bundle and is not copied into the document. Makeable recipes are derived from currently Seated bottles at display and are never stored as a second list. In-memory WellStore is the source of truth; UserDefaults is the projection. Debounce writes; flush when scenePhase becomes inactive or background; encode after every Crack, Recork, Pour, pin, and reset. Decoding failure falls back to an empty well, never a crash. Views never touch UserDefaults. resetAllData() is reachable from Settings. Tests use a private UserDefaults suite. Simulator seed only, once, behind spw.demo.v1: mark onboarding complete, write several owned bottles with several Seated on the Rail, file CrackMarks and at least one PourMark, pin at least one recipe, leave Pour able to sample a seated recipe, and never seed an empty rail or Dry as the first frame. Never seed on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Speedwell/1.0 (iOS; +https://speedwell-rail.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.food-and-drink`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.food-and-drink
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Crack-then-pour (a bottle is Backbar until Crack seats it on the Rail; Surprise samples only recipes whose bottles all sit on the Rail; Recork lifts a bottle off; Pour writes a PourMark and does not empty the bottle)

Home is tonight's well: Crack then Pour, not a dice control over the catalog. Adding a bottle writes Backbar; Surprise ignores sealed stock until Crack seats it on the Rail and writes a CrackMark. Pour samples one bundled recipe whose every required bottle currently sits on the Rail, writes a PourMark, and leaves the bottles seated. Recork lifts a bottle back to Backbar and Surprise immediately drops any recipe that needed it; Pour on an empty Rail still runs and writes Dry. Simulator seed seats several bottles so Pour is live after first launch; Discover counts makeable recipes and CrackMarks, not a shopping list.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **3D glass render glassmorphism · take cocktailbar**


This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

Base prompt, reused and extended for every asset:

```
3D glass render, glassmorphism, studio-lit home service well, frosted speed rail of bottles, refractive coupe and cork, soft bloom and depth, isolated subjects, quiet uncluttered ground, no text, no letters, no logo, no photoreal stock, no specified colours, one glass well not a grid of twin cards
```

All 15 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `spw_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `spw_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `spw_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `spw_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `spw_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `spw_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `spw_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `spw_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `spw_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `spw_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `spw_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Crack-then-pour (a bottle is Backbar until Crack seats it on the Rail; Surprise samples only recipes whose bottles all sit on the Rail; Recork lifts a bottle off; Pour writes a PourMark and does not empty the bottle)' feature screen. |
| 11 | `spw_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `spw_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `spw_RailBottle` | 1024x1024 | **required cutout** | Isolated 3D glass bottle seated on a rail fragment, cutout, transparent corners, no plate, no text |
| 14 | `spw_SealedCork` | 1024x1024 | **required cutout** | Isolated 3D glass bottle still corked, backbar stock, cutout, transparent corners, no plate, no text |
| 15 | `spw_CoupeGlass` | 1024x1024 | **required cutout** | Isolated 3D glass coupe after a pour, cutout, transparent corners, no plate, no text |

### Prompt per asset

**`spw_AppIcon`** — 1024x1024

```
A single 3D glass bottle seated on a short frosted speed rail, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
```

**`spw_Splash`** — 1290x2796

```
A tall vertical 3D glass service well, frosted rail receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text
```

**`spw_Onboarding1`** — 1024x1536

```
3D glass still life of a home bartender at an empty well with sealed bottles on the backbar, the product in one glance, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_Onboarding2`** — 1024x1536

```
3D glass mid-gesture: a cork leaving a bottle as it seats onto the speed rail, Crack then Pour, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_Onboarding3`** — 1024x1536

```
3D glass well after several seated bottles: a poured coupe on the rail, meaning accumulated, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_EmptyHome`** — 1024x1024

```
An empty 3D glass speed rail with no seated bottles, waiting, calm and inviting, never sad, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_EmptyList`** — 1024x1024

```
An empty 3D glass pin rail with no favorite recipes, calm, isolated cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_CardBackdrop`** — 1200x800

```
Abstract low-contrast 3D frosted glass rail and faint pour bloom, quiet enough for text on top, filling the canvas, no letters
```

**`spw_ControlFace`** — 512x512

```
The face of a small glass pour spout, 3D glass cutout, isolated, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_TwistHero`** — 1024x1024

```
3D glass emblem of crack-then-pour: a cork lifting as a bottle seats on the rail beside a waiting coupe, glassmorphism cutout, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_SuccessMark`** — 512x512

```
A poured 3D glass coupe with a quiet pour bead, confirmation not fireworks, isolated cutout, no letters

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_HeaderDecor`** — 1200x600

```
A wide low 3D glass speed-rail band of bottle necks, frosted glassmorphism, low contrast, no readable text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_RailBottle`** — 1024x1024

```
Isolated 3D glass bottle seated on a rail fragment, cutout, transparent corners, no plate, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_SealedCork`** — 1024x1024

```
Isolated 3D glass bottle still corked, backbar stock, cutout, transparent corners, no plate, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`spw_CoupeGlass`** — 1024x1024

```
Isolated 3D glass coupe after a pour, cutout, transparent corners, no plate, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated subject, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`spw.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.


---

## 17. Tests

Add a unit test target `SpeedwellTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Speedwell -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Rail ADT fold (Backbar | Seated); the well is a fold over Bottles; Crack writes a CrackMark and seats the bottle on the Rail; Surprise samples recipes whose bottles are all Seated; Recork returns Seated to Backbar; Pour writes a PourMark and does not empty the bottle; empty Rail writes Dry** with no leakage across layers.
- [ ] UI approach matches **SwiftUI pure · take cocktailbar**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Well-link chrome (Surprise holds the well; pour fuses on Surprise; Bar, Discover, Favorites and Settings arrive as sheets; App Intents and URLs route into those sheets or onto Pour)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Speedwell
xcodegen generate
xcodebuild -scheme Speedwell -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Speedwell -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
