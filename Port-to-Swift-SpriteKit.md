# TD Launch: Swift / SpriteKit Port Spec

## Goal

Port TD Launch from Objective-C / Cocos2D / ObjectiveChipmunk to Swift / SpriteKit, targeting modern iOS. The game logic, levels, art, audio, and IAP products do not change. The result should be identical in gameplay and feel to the current version.

---

## What Does Not Change

- All 10 levels + tutorial (`.idraw` source files, `.json` metadata, exported level images)
- All art assets (PNGs, sprite atlases, font files)
- All audio assets (MP3/M4A files in `Artwork/Audio/`)
- ~~Game Center~~ — removed (see below)
- Scoring logic (score, gems, distance, stars calculation)
- Save file location convention (`L{N}.dat` / `L{N}data.dat` in Documents directory)
- The gameplay-based unlock system in `applyLevelData` — completing levels and earning stars still awards tools and characters exactly as before

---

## Architecture Map

| Current | Replacement |
|---|---|
| `CCNode` / `CCLayer` | `SKNode` / `SKScene` |
| `CCSprite` | `SKSpriteNode` |
| `CCSpriteFrame` | `SKTexture` |
| `CCAction` | `SKAction` |
| `CCDirector` | `SKView` |
| `CCLabelBMFont` / `CCLabelAtlas` | `SKLabelNode` |
| `CCScene` | `SKScene` |
| `ChipmunkSpace` | `SKPhysicsWorld` (on `SKScene`) |
| `ChipmunkSegmentShape` | `SKPhysicsBody(edgeFrom:to:)` |
| `ChipmunkPolyShape box` | `SKPhysicsBody(rectangleOf:)` |
| `ChipmunkPolyShape poly` | `SKPhysicsBody(polygonOf:)` |
| `ChipmunkBody` | `SKPhysicsBody` (on `SKSpriteNode`) |
| `PhysicsSprite` | `SKSpriteNode` with `.physicsBody` |
| `CCLayerPanZoom` | `SKCameraNode` + `UIPanGestureRecognizer` / `UIPinchGestureRecognizer` |
| `SimpleAudioEngine` | `AVAudioPlayer` (music) + `AVAudioEngine` or `SKAction.playSoundFileNamed` (SFX) |
| `iAd` | Removed entirely |
| `NSCoding` / `NSKeyedArchiver` | `Codable` + `JSONEncoder` (with migration path for existing saves) |
| `CCNode*` params | `SKNode` params |
| `ccTime` / `update:` | `update(_ currentTime:)` |
| `CCDirector sharedDirector` | Direct `SKView` / scene size references |
| `.h` + `.m` file pairs | Single `.swift` files |
| `SCRNX(x)` / `SCRNY(y)` macros | `x` / `y` — bare design-space values; SpriteKit scene handles device scaling |
| `Screen.h/.m` | Deleted |

---

## Removed Features

### In-App Purchases

StoreKit and all IAP code are removed entirely. The three IAP products (`SuperStartPack`, `PowerPack`, `DevPack`) each granted additional tool counts on top of what gameplay awarded. Those bonuses are simply gone — gameplay earning is the only path.

Files deleted as a result:
- `ProductIds.h/.m` → `ProductIds.swift` is **not created**; all product/tool name constants go away
- `AppStore.h/.m` (store mode) → the store UI is removed; the help screen is kept as a standalone `HelpScene` (see below)

The `AppStore` scene had two modes: `sceneAsStore` (purchases at top) and `sceneAsHelp` (tool descriptions). Only the help mode survives, renamed `HelpScene`. It shows what each tool does and how to earn it — no price labels, no buy buttons.

### Tamper Detection

`Achievements` used SHA1 hashes of the save file to detect manual edits (protecting purchased tool counts from being inflated). With IAP gone there's nothing to protect, so the entire tamper-detection mechanism (`getHashForVersion2`, `getHashForVersion3`, `isTampered`, `FILEVERSION_HASH`, `DATAVALUES_HASH`) is removed. `Achievements.swift` is a straightforward `Codable` struct.

### Game Center

Game Center is removed entirely. The leaderboard and achievement integrations were never a meaningful part of the experience and the leaderboard was compromised. `GameCenter.h/.m` is not ported. The `gameCenter` toggle in `Settings` is removed. Any Game Center entitlement is dropped from the app target.

---

## Developer Mode

A `devMode` flag is added to `Settings`. When enabled:
- All tool counts behave as if they are effectively unlimited (return a large fixed value, e.g. 99, regardless of what is saved)
- All characters (Bruce, Toby, Angie) are available
- `Achievements.applyLevelData()` still runs normally, so earned counts still accumulate in the background

`devMode` is stored in `UserDefaults` (not in the achievements save file) so it persists across app launches and is clearly separate from earned state.

**Activation**: long-press the version label on the settings screen for 3 seconds. A subtle confirmation — brief haptic tap + the label text briefly reads "DEV MODE ON" or "DEV MODE OFF" — lets you know it registered without being obvious to a casual observer.

`devMode` is exposed as a read-only computed property on `Achievements` so callers don't need to know where it comes from:

```swift
var effectivePlankCount: Int {
    Settings.globalSettings.devMode ? 99 : plank
}
```

---

## Key Technical Decisions

### Physics Collision Types

Chipmunk uses pointer identity for collision types (the `NSString*` constants in `CollisionTypes.h`). SpriteKit uses 32-bit bitmasks (`categoryBitMask`, `contactTestBitMask`, `collisionBitMask`).

Replace `CollisionTypes.h/.m` with a Swift struct:

```swift
struct PhysicsCategory {
    static let character:        UInt32 = 1 << 0
    static let launchPad:        UInt32 = 1 << 1
    static let launchPadSegment: UInt32 = 1 << 2
    static let target:           UInt32 = 1 << 3
    static let gem:              UInt32 = 1 << 4
    static let sensor:           UInt32 = 1 << 5
    static let trampoline:       UInt32 = 1 << 6
    static let blower:           UInt32 = 1 << 7
    static let plank:            UInt32 = 1 << 8
    static let slide:            UInt32 = 1 << 9
    static let boulder:          UInt32 = 1 << 10
    static let launcher:         UInt32 = 1 << 11
    static let projectile:       UInt32 = 1 << 12
    static let areaSensor:       UInt32 = 1 << 13
    static let accelerator:      UInt32 = 1 << 14
    static let namedWall:        UInt32 = 1 << 15
    static let noBottomCollision:UInt32 = 1 << 16
}
```

Collision handling moves from Chipmunk's callback system to `SKPhysicsContactDelegate` on `GameScene`.

### Coordinate System

Both Cocos2D and SpriteKit use bottom-left origin, so level coordinate data does not change. The `SCRNX` / `SCRNY` macros in `Screen.h` are fully deleted — they served only to scale from a 1024×768 design space to device pixels, and SpriteKit makes them unnecessary.

**The approach:** set `scene.size = CGSize(width: 1024, height: 768)` and `scene.scaleMode = .aspectFill`. SpriteKit then maps every point in the scene 1:1 to your design coordinates and handles the physical pixel scaling automatically. All positions, sizes, and physics values throughout the codebase are expressed as plain design-space numbers — no wrapping macros.

For scrolling levels (where the level is taller or wider than 768/1024), the scene size stays at the viewport dimensions. Level geometry extends beyond the viewport in design coordinates, and `SKCameraNode` pans through it. This is already how the original worked (a game layer that was offset), just expressed more cleanly.

This means:
- `Screen.h/.m` is deleted, not ported
- Every `SCRNX(x)` in `GameLayer.m` becomes just `x`
- Every `SCRNY(y)` becomes just `y`
- Generated level code (Phase 5) emits bare `CGPoint` / `CGSize` / `CGVector` literals with no scaling wrapper

### Pan / Zoom

Replace `CCLayerPanZoom` (809 lines of customized Chipmunk gesture handling) with:
- An `SKCameraNode` attached to `GameScene`
- `UIPanGestureRecognizer` to translate the camera
- `UIPinchGestureRecognizer` to zoom (update `camera.xScale` / `yScale`)
- Clamp pan/zoom to level bounds in the gesture handler

The custom tuning you had in the original `CCLayerPanZoom` (pan-frame margins, momentum behavior) should be re-derived by feel during Phase 3 testing rather than by transcribing line-by-line.

### Persistence / Save Files

`GameData` and `GameConfig` currently use `NSCoding` / `NSKeyedArchiver`. The Swift port should use `Codable` + `JSONEncoder`.

Existing player save files (`.dat`) are `NSKeyedArchiver` archives. These are dropped — no migration. Implement `Codable` + `JSONEncoder` for all saved types from the start and ignore any legacy files.

### iAd Removal

Remove all `#import <iAd/iAd.h>` references and all ad banner layout code in `GameLayer`. The ad offset variables (`mainScoreLabelAdHidY`, `mainScoreLabelAdVisY`, etc.) in `GameLayer.h` go away. Score label positions become fixed.

### Characters

`CCSpriteFrame` properties on `CharacterDefinition` become `SKTexture`. The `createInSpace:position:angle:` method becomes `createBody(in scene: GameScene, position: CGPoint, angle: CGFloat) -> SKSpriteNode`.

---

## Phase Plan

### Phase 1 — Foundation (no game yet, just compiles)

**New Xcode project**: Swift, SpriteKit, iPad-only, minimum deployment target iPadOS 16. Device family set to iPad only — Universal/iPhone support is deferred.

Files to create / port:

| ObjC source | Swift replacement | Notes |
|---|---|---|
| `AppDelegate.h/.m` | `AppDelegate.swift` | Minimal; just wire `SKView` to window |
| `Screen.h/.m` | Delete | `SCRNX`/`SCRNY` macros replaced by SpriteKit scene scaling — set `scene.size` and `scaleMode = .aspectFill`, use bare coordinates everywhere |
| `Settings.h/.m` | `Settings.swift` | `NSCoding` → `Codable`, `UserDefaults` or JSON file |
| `CollisionTypes.h/.m` | `PhysicsCategory.swift` | See above |
| `ProductIds.h/.m` | `ProductIds.swift` | Straight constant translation |
| `EventManager.h/.m` | Delete | Replace with Swift closures / `NotificationCenter` / delegation as needed |

### Phase 2 — Data Model

Files to port:

| ObjC source | Swift replacement | Notes |
|---|---|---|
| `GameData.h/.m` | `GameData.swift` | `NSCoding` → `Codable`. `ActiveFieldObject` encodes placed objects. |
| `Achievements.h/.m` | `Achievements.swift` | Singleton stays. `NSCoding` → `Codable`. Tamper detection and `purchasedProducts` removed entirely. Add `devMode`-aware computed properties. |
| `GameCenter.h/.m` | Deleted | Game Center removed entirely |
| `AppStore.h/.m` | Deleted (store mode) / `HelpScene.swift` (help mode) | StoreKit removed. Help UI (tool descriptions, how to earn each) survives as a standalone scene with no price labels or buy buttons. |
| `Character.h/.m` | `Character.swift` | `CCSpriteFrame` → `SKTexture`. `createInSpace:` → `createBody(in:position:angle:)`. |
| `Animation.h/.m` | `Animation.swift` | `ChipmunkBody` → `SKSpriteNode`. `RotationAnimation` → `SKAction.repeatForever(.rotate(...))` may be simpler than keeping the manual frame-by-frame logic. |
| `FieldObject.h/.m` | `FieldObject.swift` | Large file; keep the `FieldObjectType` enum and factory pattern. Physics body creation replaces Chipmunk shape creation. |
| `GameLevel.h/.m` | `GameLevel.swift` | `createSpace()` → `configurePhysics(in scene: GameScene)`. `NSCoding` save/load stays structurally the same but uses `Codable`. |

### Phase 3 — Game Scene (the big one)

`GameLayer.m` (3,305 lines) becomes `GameScene.swift`. This is a rewrite using `GameLayer.m` as a behavioral specification, not a line-by-line translation.

Work items within this phase:

1. **Scene setup**: `viewDidLoad` equivalent — create physics world, set gravity/damping from level, add camera node.
2. **Level loading**: Call `GameLevel.configurePhysics(in:)`, call `level.addScenery(to:)`.
3. **Character spawning**: Add character sprite to scene with physics body.
4. **Drawers (object picker)**: Port `Drawer.h/.m` and `ScrollView.h/.m` — these are the bottom-screen tool drawers. Consider using `UIScrollView` or a custom `SKNode` scroll implementation.
5. **Gesture handling**: Pan/zoom camera (see above). Tap-to-place field objects. Long-press to remove.
6. **Physics contact delegate**: One `didBegin(_ contact:)` method handles what the original had spread across multiple Chipmunk collision handlers:
   - Character ↔ LaunchPad → apply launch force
   - Character ↔ Target → record target touch event, award score
   - Character ↔ Gem → collect gem, remove from scene
   - Character ↔ Sensor → apply sensor effect (ApplyForce, ToggleSprite, TogglePhysics)
   - Character ↔ AreaSensor → same
7. **`update(_ currentTime:)`**: Run animations (Rotation, Oscillation, FollowPath), update score/distance labels, manage projectile sources, track player position for camera auto-pan, detect level end conditions.
8. **Projectile sources**: Port `ProjectileSource` from `GameLayer.m` — periodic spawning of physics objects (birds, planks, slides).
9. **Score / recap screen**: Port the end-of-level results panel and star calculation.
10. **Rotation / launcher settings dialogs**: Port `RotationSettingsDialog` and `LauncherObjectSettingsDialog` — these appear when you tap a placed object.
11. **Debug layer**: Port `CPDebugLayer` → optional `SKShapeNode` overlay that draws physics shapes. Useful during development.

**`PhysicsSprite.h/.m`**: This was a bridge between Cocos2D nodes and Chipmunk bodies (Chipmunk had no native sprite attachment). In SpriteKit, `SKSpriteNode` has `.physicsBody` natively — `PhysicsSprite` disappears entirely.

**`AutoPanLayer.h/.m`**: The auto-pan-to-follow-player logic moves into `GameScene.update()` as camera position logic.

**`RulerNode.h/.m`**: Port as a debug/placement aid — draws a rotation ruler when placing field objects.

**`ColoredNode.h/.m`**: Port as a simple `SKShapeNode` subclass or utility extension.

### Phase 4 — Remaining Scenes and UI

| ObjC source | Swift replacement |
|---|---|
| `IntroLayer.h/.m` | `IntroScene.swift` |
| `MainMenu.h/.m` | `MainMenuScene.swift` |
| `LevelMenu.h/.m` | `LevelMenuScene.swift` |
| `AppStore.h/.m` (UI part) | `HelpScene.swift` — tool descriptions and how to earn each; no store, no prices |
| `Dialog.h/.m` | `Dialog.swift` — base class for overlay dialogs |
| `YesNoDialog.h/.m` | `YesNoDialog.swift` |
| `TutorialDialog.h/.m` | `TutorialDialog.swift` |
| `AppSettingsDialog.h/.m` | `AppSettingsDialog.swift` |
| `SaneMenu.h/.m` | Delete — was a workaround for a Cocos2D menu bug; use `SKNode` button nodes |
| `GestureRecognizerWithBlock.h/.m` | Delete — use Swift closures directly with `UIGestureRecognizer` |
| `HelloWorldLayer.h/.m` | Delete — was scaffolding, not used in production |
| `CPDebugLayer.h/.m` | `PhysicsDebugLayer.swift` — optional, keep for dev builds |

### Phase 5 — Level Code Generator (secondary, non-blocking)

Update the `Artwork/idraw_to_gamelevel` Python script:

**Python 3 fixes** (4 changes):
- `print >> sys.stderr, msg` → `print(msg, file=sys.stderr)`
- `file(mdFile,"r").read()` → `open(mdFile).read()`
- `plistlib.readPlistFromString(plistStr)` → `plistlib.loads(plistStr)`
- `print header` / `print code` → `print(header)` / `print(code)`

**Swift code generation** — rewrite `SpaceDefinition.generate()` to emit a single `.swift` file instead of `.h` + `.m`:

```python
def generate_swift(self):
    code = f'// AUTO-GENERATED: LEVEL {self.ID}\n'
    code += f'class GameLevel_{self.ID}: GameLevel {{\n'
    code += f'  override var debug: Bool {{ return {"true" if self.debug else "false"} }}\n\n'
    code += f'  override func initLevel() {{\n'
    code += f'    id = {self.ID}\n'
    code += f'    gameSize = CGSize(width: {self.width}, height: {self.height})\n'
    # gems...
    # etc.
```

Key translation table for generated code:

| ObjC generated | Swift generated |
|---|---|
| `CGSizeMake(SCRNX(w), SCRNY(h))` | `CGSize(width: w, height: h)` — raw design values |
| `ccp(SCRNX(x), SCRNY(y))` | `CGPoint(x: x, y: y)` — raw design values |
| `cpv(x, y)` | `CGVector(dx: x, dy: y)` |
| `[[ChipmunkSegmentShape alloc] initWithBody:... from:... to:... radius:r]` | `SKPhysicsBody(edgeFrom: CGPoint(...), to: CGPoint(...))` |
| `[ChipmunkPolyShape boxWithBody:... width:w height:h]` | `SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))` |
| `.collisionType = CT_LaunchPad` | `.categoryBitMask = PhysicsCategory.launchPad` |
| `[[CCSprite alloc] initWithFile:@"img.png"]` | `SKSpriteNode(imageNamed: "img")` |
| `[CCSprite spriteWithFile:@"img.png"]` | `SKSpriteNode(imageNamed: "img")` |
| `[self loadImage:@"img.png"]` | `SKSpriteNode(imageNamed: "img")` |
| `@interface GameLevel_N : GameLevel\n@end` | (deleted — no header needed) |
| `@implementation GameLevel_N` | `class GameLevel_N: GameLevel {` |
| `@end` | `}` |

Until Phase 5 is complete, the existing ObjC-generated level files can stay in the project as a reference. The Swift port does not depend on regenerating them.

---

## File Deletion List

These files have no Swift equivalent and should not be ported:

- `HelloWorldLayer.h/.m` — scaffolding
- `SaneMenu.h/.m` — Cocos2D workaround
- `GestureRecognizerWithBlock.h/.m` — replaced by Swift closures
- `PhysicsSprite.h/.m` — replaced by native SpriteKit physics bodies
- `Prefix.pch` — not used in Swift
- `main.m` — replaced by `@main` or `AppDelegate.swift`
- `CCLayerPanZoom.h/.m` — replaced by `SKCameraNode` + gesture recognizers
- `EventManager.h/.m` — replaced by delegation / closures
- `ProductIds.h/.m` — IAP removed; all product/tool name constants deleted
- `GameCenter.h/.m` — Game Center removed entirely
- All `#import` chain (`cocos2d.h`, `ObjectiveChipmunk.h`, `chipmunk.h`)
- `Screen.h/.m` — replaced by scene `size` constant

---

## Suggested Order of Attack

1. New Xcode project + `AppDelegate` + blank `SKScene` on screen
2. `PhysicsCategory`, `Settings`, `ProductIds`, `GameData`, `Achievements` (no UI)
3. `Character`, `FieldObject`, `Animation` (pure logic, no rendering yet)
4. `GameLevel` base class + one hard-coded test level loading into a scene
5. Physics contact handling for the core game loop (launch → target)
6. Gem collection, sensor triggers, score tracking
7. `GameScene` complete with drawers, dialogs, pan/zoom
8. `LevelMenu`, `MainMenu`, `IntroScene`
9. `AppStore` scene (help + IAP)
10. Audio
12. QA pass on all 10 levels
13. Level generator Python 3 + Swift output update

---

## Open Questions

- **Developer mode activation**: ~~Resolved~~ — long-press on version label in settings screen, persisted in `UserDefaults`.
- **Game Center**: ~~Resolved~~ — removed entirely.
- **Minimum iOS version**: ~~Resolved~~ — iPadOS 16.
- **iPhone support**: ~~Resolved~~ — iPad-only for this port; iPhone support to follow once the port is stable.
- **Save file migration**: ~~Resolved~~ — old `NSKeyedArchiver` saves dropped; no migration.
- **iDraw / Vectornator**: Deferred — confirm the level editor workflow still works before starting Phase 5.
