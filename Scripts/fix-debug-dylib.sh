#!/bin/bash
# Fix debug.dylib framework paths after build
# This script fixes the incorrect framework paths in debug.dylib

APP_PATH="$1"
if [ -z "$APP_PATH" ]; then
    # Find the most recent build
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/FightCityTickets-*/Build/Products/Debug-iphonesimulator/FightCityTickets.app -type d 2>/dev/null | head -1)
fi

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "App not found"
    exit 1
fi

DYLIB_PATH="$APP_PATH/FightCityTickets.debug.dylib"

if [ -f "$DYLIB_PATH" ]; then
    echo "Fixing framework paths in debug.dylib..."
    install_name_tool -change /Library/Frameworks/FightCityiOS.framework/FightCityiOS @rpath/FightCityiOS.framework/FightCityiOS "$DYLIB_PATH" 2>/dev/null
    install_name_tool -change /Library/Frameworks/FightCityFoundation.framework/FightCityFoundation @rpath/FightCityFoundation.framework/FightCityFoundation "$DYLIB_PATH" 2>/dev/null
    echo "✅ Fixed debug.dylib"
else
    echo "debug.dylib not found"
fi
