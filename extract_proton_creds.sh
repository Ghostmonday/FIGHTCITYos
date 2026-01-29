#!/bin/bash

CHROME_DATA="/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default"
PROTON_PASS_DATA="/home/evan/.config/Proton Pass/Partitions/app"

echo "=== EXTRACTING PROTON CREDENTIALS ==="
echo ""

# Check if Chrome is running
if pgrep -f "chrome|chromium" > /dev/null; then
    echo "⚠️  Chrome is running. Please close Chrome first, then run this script again."
    echo "   Or run: pkill chrome"
    exit 1
fi

# Copy Login Data to temp location (Chrome locks it)
TEMP_LOGIN="/tmp/chrome_login_data_$$"
cp "$CHROME_DATA/Login Data" "$TEMP_LOGIN" 2>/dev/null

if [ -f "$TEMP_LOGIN" ]; then
    echo "📋 PROTON LOGIN CREDENTIALS:"
    sqlite3 "$TEMP_LOGIN" "SELECT origin_url, username_value FROM logins WHERE origin_url LIKE '%proton%';" 2>/dev/null
    echo ""
    rm -f "$TEMP_LOGIN"
else
    echo "❌ Could not access Login Data"
fi

# Check Cookies for Proton sessions
echo "🍪 PROTON COOKIES (Active Sessions):"
sqlite3 "$CHROME_DATA/Cookies" "SELECT host_key, name, value FROM cookies WHERE host_key LIKE '%proton%' LIMIT 20;" 2>/dev/null
echo ""

# Check Proton Pass Local Storage
echo "📝 PROTON PASS LOCAL STORAGE:"
if [ -d "$PROTON_PASS_DATA/Local Storage" ]; then
    find "$PROTON_PASS_DATA/Local Storage" -type f -name "*proton*" -exec echo "Found: {}" \;
fi
echo ""

# Check Proton Pass IndexedDB (might contain notes!)
echo "🗄️  PROTON PASS INDEXEDDB (May contain your notes!):"
if [ -d "$PROTON_PASS_DATA/IndexedDB" ]; then
    find "$PROTON_PASS_DATA/IndexedDB" -type f | head -10
    echo ""
    echo "Checking for note/recovery data..."
    find "$PROTON_PASS_DATA/IndexedDB" -type f -exec grep -l "recovery\|12 words\|seed\|backup" {} \; 2>/dev/null | head -5
fi
echo ""

# Check Session Storage
echo "💾 PROTON PASS SESSION STORAGE:"
if [ -d "$PROTON_PASS_DATA/Session Storage" ]; then
    find "$PROTON_PASS_DATA/Session Storage" -type f | head -5
fi

echo ""
echo "=== DONE ==="
