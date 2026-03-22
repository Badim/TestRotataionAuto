# Runtime orientation plugin — saved instructions

This folder holds the **Android native** source for `plugin.orientation`, which calls `Activity.setRequestedOrientation()` from Lua. **iOS is not implemented here** (needs a separate Xcode static library).

**Files in this repo**

| Path | Role |
|------|------|
| `native_plugin_orientation/android/.../LuaLoader.java` | Android plugin entry (`plugin.orientation.LuaLoader`) |
| `plugins/plugin.orientation.lua` | Simulator / no-JAR stub: `orientation.set()` is a no-op |
| `build.settings` (comment) | Example `plugins` entry (commented until JAR is wired) |

---

## Quick checklist (what you must do)

1. Install **Solar2D** and **Solar2D Native** (includes `Native/Project Template/App/android`).
2. Copy **`LuaLoader.java`** into the Native template:  
   `plugin/src/main/java/plugin/orientation/LuaLoader.java`  
   (package must stay **`plugin.orientation`**.)
3. Open the template **`android`** project in **Android Studio**, build the **plugin** module, and locate the output **`.jar`** (often under `plugin/build/outputs/`).
4. Install that JAR using **one** workflow Solar2D supports: local `plugins/` layout, **`%APPDATA%\Solar2DPlugins\...`**, or a **self-hosted `.tgz`**. See [Self-Hosted Plugins](https://docs.coronalabs.com/native/hostedPlugin.html).
5. In your game’s **`build.settings`**, add:

   ```lua
   plugins = {
     ["plugin.orientation"] = { publisherId = "com.yourcompany" },
   },
   ```

   Replace `com.yourcompany` with your real reverse-DNS id (must match plugin packaging rules you use).

6. In Lua:

   ```lua
   local orientation = require("plugin.orientation")
   orientation.set("landscape")         -- fixed landscape (primary)
   orientation.set("landscapeSensor")   -- either landscape, follows sensor
   orientation.set("portrait")
   orientation.set("sensor")            -- full sensor
   orientation.set("user")              -- user / system default
   ```

7. Keep app **`orientation.supported`** in `build.settings` consistent with what you request at runtime.

**Simulator:** use the stub in `plugins/plugin.orientation.lua` or configure `supportedPlatforms` so builds do not expect a missing native binary. If `require` fails, check Solar2D docs for your Simulator plugin path.

**iOS:** requires a **`.a`** plugin in the Solar2D Native **iOS** template (Objective‑C/Swift), not this Java code.

---

## Detailed steps

### 1. Prerequisites

- [Solar2D](https://solar2d.com/)
- **Solar2D Native** (Native folder with **App** project template)
- **Android Studio** (Gradle) to compile the plugin JAR

### 2. Copy Java into the Native plugin module

1. Open: **`<Solar2D>/Native/Project Template/App/android`**
2. In the **`plugin`** module: `plugin/src/main/java/`
3. Create **`plugin/orientation/`** and copy **`LuaLoader.java`** from this repo:

   `native_plugin_orientation/android/plugin/src/main/java/plugin/orientation/LuaLoader.java`

The class **`plugin.orientation.LuaLoader`** must match `require("plugin.orientation")`.

### 3. Build the plugin JAR

- Open **`android`** in Android Studio.
- Build the **plugin** module; find the Gradle task that exports the JAR (e.g. `exportPluginJar` or **Make Module** `plugin`).
- If the build fails, ensure `plugin/build.gradle` references Corona/Solar2D JARs from the Native install ([Solar2D Native Android](https://docs.coronalabs.com/native/android/index.html)).

### 4. Add the JAR to the game project

Choose one:

- **A.** Local plugins directory — mirror [marketplace / packaging](https://www.solar2dplugins.com/asset-packaging-guidelines) (`android/` + `metadata.lua` if required).
- **B.** Windows: `%APPDATA%\Solar2DPlugins\<publisherId>\plugin.orientation\android\data.tgz`
- **C.** Hosted URL in `supportedPlatforms` ([Self-Hosted Plugins](https://docs.coronalabs.com/native/hostedPlugin.html)).

### 5. `build.settings`

Enable the `plugins` table as in the checklist above.

### 6. Lua API

Mode strings are mapped in **`LuaLoader.mapMode()`** (Android `ActivityInfo` constants), including:  
`landscape`, `landscapeLeft` / `landscapeReverse`, `landscapeRight`, `landscapeSensor`, `portrait`, `portraitUpsideDown` / `portraitReverse`, `portraitSensor`, `sensor`, `fullSensor`, `user`, `unspecified`, etc.

### 7. Orientation policy

`orientation.default` and `orientation.supported` in **`build.settings`** should align with runtime locks; odd combinations can misbehave on some devices.

---

## AI / repo vs. you

| Task | Who |
|------|-----|
| Java `LuaLoader`, Lua stub, this doc | In repo |
| Install Native, Gradle build, place JAR/tgz | You |
| `publisherId`, `build.settings`, device testing | You |
| iOS `.a` plugin | Separate Xcode work |

---

## iOS note (not in this folder)

On iOS, runtime orientation is usually done by updating **supported interface orientations** on the root view controller and calling **`setNeedsUpdateOfSupportedInterfaceOrientations()`** (iOS 16+). Implement that in a **static library** from the Solar2D Native **iOS** plugin template.

---

## References

- [Solar2D Native — Plugins](https://docs.coronalabs.com/native/plugin/index.html)
- [Self-Hosted Plugins](https://docs.coronalabs.com/native/hostedPlugin.html)
- [Solar2D Native — Android](https://docs.coronalabs.com/native/android/index.html)
