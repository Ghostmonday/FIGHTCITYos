#!/bin/bash

echo "=== EXTRACTING PROTON SESSION DATA ==="
echo ""

COOKIES_DB="/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default/Cookies"
LOGIN_DB="/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default/Login Data"

# Extract cookies
echo "🍪 PROTON COOKIES (Full Values):"
sqlite3 "$COOKIES_DB" <<EOF
.mode column
.headers on
SELECT host_key, name, substr(value, 1, 100) as value_preview, 
       datetime(expires_utc/1000000-11644473600, 'unixepoch') as expires
FROM cookies 
WHERE host_key LIKE '%proton%' 
ORDER BY host_key, name;
EOF

echo ""
echo "📋 PROTON LOGIN CREDENTIALS:"
if [ -f "$LOGIN_DB" ]; then
    cp "$LOGIN_DB" /tmp/login_temp.db 2>/dev/null
    sqlite3 /tmp/login_temp.db <<EOF
.mode column
.headers on
SELECT origin_url, username_value 
FROM logins 
WHERE origin_url LIKE '%proton%';
EOF
    rm -f /tmp/login_temp.db
else
    echo "Login Data file not accessible"
fi

echo ""
echo "=== IMPORTANT COOKIES TO RESTORE SESSION ==="
echo ""
echo "To restore your session, you need these cookies:"
sqlite3 "$COOKIES_DB" <<EOF
SELECT 'Cookie: ' || name || '=' || value || '; Domain=' || host_key || '; Path=' || path
FROM cookies 
WHERE host_key LIKE '%proton%' 
  AND (name LIKE '%AUTH%' OR name LIKE '%REFRESH%' OR name LIKE '%Session%')
ORDER BY host_key;
EOF
