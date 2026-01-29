#!/usr/bin/env python3
import sqlite3
import json
import os

COOKIES_DB = "/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default/Cookies"

if not os.path.exists(COOKIES_DB):
    print("❌ Cookies database not found!")
    exit(1)

conn = sqlite3.connect(COOKIES_DB)
cursor = conn.cursor()

print("=== PROTON SESSION COOKIES ===\n")

# Get all Proton cookies
cursor.execute("""
    SELECT host_key, name, value, path, expires_utc, is_secure, is_httponly
    FROM cookies 
    WHERE host_key LIKE '%proton%'
    ORDER BY host_key, name
""")

cookies = cursor.fetchall()

if cookies:
    print("Found {} Proton cookies:\n".format(len(cookies)))
    
    # Group by domain
    domains = {}
    for cookie in cookies:
        domain = cookie[0]
        if domain not in domains:
            domains[domain] = []
        domains[domain].append(cookie)
    
    # Print cookies that might give session access
    important_cookies = ['AUTH', 'REFRESH', 'Session-Id', 'connect.sid']
    
    for domain, domain_cookies in domains.items():
        print(f"\n📍 {domain}:")
        for cookie in domain_cookies:
            name = cookie[1]
            value = cookie[2]
            if name in important_cookies or len(value) > 20:
                print(f"  {name}: {value[:50]}..." if len(value) > 50 else f"  {name}: {value}")
    
    # Create browser extension format
    print("\n\n=== TO USE IN BROWSER ===")
    print("Install 'EditThisCookie' or 'Cookie-Editor' extension")
    print("Then import these cookies manually, or:")
    print("\nOr use this JavaScript in browser console:")
    print("\n// Run this on account.proton.me:")
    for cookie in cookies:
        if cookie[0] == 'account.proton.me' and cookie[1] in ['AUTH', 'REFRESH']:
            print(f"document.cookie = '{cookie[1]}={cookie[2]}; path={cookie[3]}; domain={cookie[0]}';")
    
    # Save to file
    with open('/tmp/proton_cookies.json', 'w') as f:
        cookie_list = []
        for cookie in cookies:
            cookie_list.append({
                'domain': cookie[0],
                'name': cookie[1],
                'value': cookie[2],
                'path': cookie[3]
            })
        json.dump(cookie_list, f, indent=2)
    
    print(f"\n✅ Cookies saved to: /tmp/proton_cookies.json")
else:
    print("❌ No Proton cookies found!")

conn.close()
