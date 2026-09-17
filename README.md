# Speedwell

Pour one cocktail from the bottles on your rail.

Speedwell is for home bartenders who already own bottles and want one drink they can mix tonight. It is not a recipe browser, not a shopping list, and not a delivery app.

## Architecture

A Bottle is a closed fold with two seats: **Backbar** (owned, still sealed) and **Seated** (on tonight's rail). A third role is a defect.

The well is a fold over those bottles, not a second stock list.

- Adding a bottle writes Backbar. Surprise ignores it.
- **Crack** writes a **CrackMark**, seats the bottle on the **Rail**, and yields Seated.
- **Surprise** samples one bundled **Recipe** whose every required bottle currently sits Seated. It never samples the full catalog and never samples Backbar-only stock.
- **Recork** returns Seated to Backbar. Surprise immediately drops any recipe that needed that bottle.
- **Pour** writes a **PourMark**, leaves bottles Seated, and does not empty them.
- Pour on an empty Rail still runs and writes **Dry**.

This pattern fits the product because the job is tonight's well, not a dice button over a catalog. `WellStore` is the observable fold. Views call `crack`, `recork`, and `pourWell` and never keep a second stock enum. Makeable recipes are derived from currently Seated bottles at display.

Well-link chrome keeps **Surprise** on screen. Pour fuses on that well. Bar, Discover, Favorites, and Settings arrive as sheets. App Intents and `speedwell://` URLs route into those same jobs.

## Crack then pour

Home is the well. A bottle stays Backbar until Crack seats it. Pour samples only the rail. Recork lifts a bottle and the makeable set shrinks. Simulator seed seats several bottles so Pour is live after first launch. Discover counts makeable recipes and CrackMarks, not a shopping list.

## Look

Raspberry energetic on SF Pro. Color band, heavy type, a thick rule, then a dense rail list. Cards and sheets use 16pt corners. Chips use 10pt. Elevation is Material. Tokens live in `WellPaint`, `WellType`, and `WellMeasure`. Palette: background `#F5FAF8`, surface `#FDFEFE`, ink `#183931`, accent `#2CBA96`, muted `#597870`.

Art style: 3D glass render, glassmorphism, studio-lit home service well, frosted speed rail of bottles, refractive coupe and cork, soft bloom and depth, isolated subjects, quiet uncluttered ground, no text, no letters, no logo, no photoreal stock, no specified colours, one glass well not a grid of twin cards.

### Asset prompts

**spw_AppIcon** — A single 3D glass bottle seated on a short frosted speed rail, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas

**spw_Splash** — A tall vertical 3D glass service well, frosted rail receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text

**spw_Onboarding1** — 3D glass still life of a home bartender at an empty well with sealed bottles on the backbar, the product in one glance, isolated cutout, no text

**spw_Onboarding2** — 3D glass mid-gesture: a cork leaving a bottle as it seats onto the speed rail, Crack then Pour, isolated cutout, no text

**spw_Onboarding3** — 3D glass well after several seated bottles: a poured coupe on the rail, meaning accumulated, isolated cutout, no text

**spw_EmptyHome** — An empty 3D glass speed rail with no seated bottles, waiting, calm and inviting, never sad, isolated cutout, no text

**spw_EmptyList** — An empty 3D glass pin rail with no favorite recipes, calm, isolated cutout, no text

**spw_CardBackdrop** — Abstract low-contrast 3D frosted glass rail and faint pour bloom, quiet enough for text on top, filling the canvas, no letters

**spw_ControlFace** — The face of a small glass pour spout, 3D glass cutout, isolated, no text

**spw_TwistHero** — 3D glass emblem of crack-then-pour: a cork lifting as a bottle seats on the rail beside a waiting coupe, glassmorphism cutout, no text

**spw_SuccessMark** — A poured 3D glass coupe with a quiet pour bead, confirmation not fireworks, isolated cutout, no letters

**spw_HeaderDecor** — A wide low 3D glass speed-rail band of bottle necks, frosted glassmorphism, low contrast, no readable text

**spw_RailBottle** — Isolated 3D glass bottle seated on a rail fragment, cutout, transparent corners, no plate, no text

**spw_SealedCork** — Isolated 3D glass bottle still corked, backbar stock, cutout, transparent corners, no plate, no text

**spw_CoupeGlass** — Isolated 3D glass coupe after a pour, cutout, transparent corners, no plate, no text

## Why it is not a clone

This is the first cocktail_bar in the portfolio. Home is tonight's well: Pour samples one bundled recipe whose bottles all sit on the Rail, not a dice button over the whole catalog, not numbered cook steps, and not a shelf of rated bottles. Owned stock is Backbar until Crack seats it. Scanner and remote catalog search stay unused leftovers.

## Build

```bash
cd Speedwell
xcodegen generate
xcodebuild -scheme Speedwell -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```
