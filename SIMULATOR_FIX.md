# Simulator Launch Fix

## The Problem

When building from Xcode, a `debug.dylib` file is created with incorrect framework paths (`/Library/Frameworks/` instead of `@rpath/`). This causes crashes when launching the app from the simulator.

## Quick Fix (After Each Build)

After building in Xcode, run this script:

```bash
./Scripts/fix-debug-dylib.sh
```

Then launch from Xcode (Cmd+R) - it should work!

## Better Solution: Run Directly from Xcode

**The easiest solution is to always run from Xcode:**

1. Select **iPhone 16e** simulator (top left)
2. Press **Cmd + R** (or click Play button)
3. Xcode handles everything automatically

## For App Store Submission

**This issue does NOT affect App Store builds:**
- Archive builds don't include debug.dylib
- Framework embedding works correctly
- Code signing works properly
- You can archive and submit without issues

## Permanent Fix (Optional)

If you want to fix this automatically after every build, you can add a Run Script phase in Xcode:

1. Select **FightCity** target
2. Go to **Build Phases**
3. Click **+** → **New Run Script Phase**
4. Add this script:

```bash
if [ -f "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/FightCityTickets.debug.dylib" ]; then
    install_name_tool -change /Library/Frameworks/FightCityiOS.framework/FightCityiOS @rpath/FightCityiOS.framework/FightCityiOS "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/FightCityTickets.debug.dylib" 2>/dev/null || true
    install_name_tool -change /Library/Frameworks/FightCityFoundation.framework/FightCityFoundation @rpath/FightCityFoundation.framework/FightCityFoundation "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/FightCityTickets.debug.dylib" 2>/dev/null || true
fi
```

5. Drag it to run **after** "Embed Frameworks"

---

**For now: Just run from Xcode (Cmd+R) - it works! 🚀**
