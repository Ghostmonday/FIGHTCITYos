#!/usr/bin/env python3
import sqlite3
import json
import base64
import os
from cryptography.algorithm import AES
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import subprocess

COOKIES_DB = "/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default/Cookies"

def get_chrome_key():
    """Get Chrome's encryption key from the system keyring"""
    try:
        # Try to get key from keyring
        result = subprocess.run(
            ['secret-tool', 'lookup', 'application', 'chrome'],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            return result.stdout.strip().encode()
    except:
        pass
    
    # Alternative: try to get from Chrome's Local State
    local_state_path = "/home/evan/.var/app/com.google.Chrome/config/google-chrome/Local State"
    if os.path.exists(local_state_path):
        try:
            with open(local_state_path, 'r') as f:
                local_state = json.load(f)
                encrypted_key = local_state.get('os_crypt', {}).get('encrypted_key', '')
                if encrypted_key:
                    # Decode base64
                    encrypted_key = base64.b64decode(encrypted_key)
                    # Remove 'DPAPI' prefix (Windows) or use Linux keyring
                    if encrypted_key.startswith(b'DPAPI'):
                        encrypted_key = encrypted_key[5:]
                    return encrypted_key
        except:
            pass
    
    return None

def decrypt_cookie_value(encrypted_value, key=None):
    """Decrypt Chrome cookie value"""
    if not encrypted_value:
        return ""
    
    try:
        # Chrome on Linux uses different encryption
        # Try direct access first
        if encrypted_value.startswith(b'v10') or encrypted_value.startswith(b'v11'):
            # This is Chrome's encrypted format
            # We'd need the key from keyring
            return "[ENCRYPTED - Need keyring access]"
        else:
            return encrypted_value.decode('utf-8', errors='ignore')
    except:
        return "[DECRYPTION FAILED]"

conn = sqlite3.connect(COOKIES_DB)
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

print("=== DECRYPTING PROTON COOKIES ===\n")

# Get Proton cookies
cursor.execute("""
    SELECT host_key, name, value, path, expires_utc, is_secure, is_httponly
    FROM cookies 
    WHERE host_key LIKE '%proton%'
    ORDER BY host_key, name
""")

cookies = cursor.fetchall()

if cookies:
    print(f"Found {len(cookies)} Proton cookies\n")
    
    # Focus on session cookies
    session_cookies = {}
    for cookie in cookies:
        name = cookie['name']
        if 'AUTH' in name or 'REFRESH' in name or 'Session' in name:
            domain = cookie['host_key']
            if domain not in session_cookies:
                session_cookies[domain] = []
            
            value = cookie['value']
            decrypted = decrypt_cookie_value(value)
            
            session_cookies[domain].append({
                'name': name,
                'value': decrypted if decrypted else value[:50] if value else "[EMPTY]",
                'path': cookie['path']
            })
    
    print("🔑 SESSION COOKIES (for restoring login):\n")
    for domain, cookies_list in session_cookies.items():
        print(f"📍 {domain}:")
        for cookie in cookies_list:
            print(f"  {cookie['name']}: {cookie['value']}")
            print(f"    Path: {cookie['path']}")
        print()
    
    # Also try to read raw values
    print("\n📋 ALL PROTON COOKIES (Raw):\n")
    for cookie in cookies[:10]:  # First 10
        value_preview = cookie['value'][:80] if cookie['value'] else "[EMPTY]"
        print(f"{cookie['host_key']} | {cookie['name']}: {value_preview}")
    
    print("\n\n💡 TO RESTORE SESSION:")
    print("1. Open Chrome")
    print("2. Go to https://pass.proton.me")
    print("3. Open Developer Tools (F12)")
    print("4. Go to Application > Cookies > https://pass.proton.me")
    print("5. Manually add the cookies above if session expired")
    print("\nOR try opening https://pass.proton.me directly - you might still be logged in!")
    
else:
    print("❌ No Proton cookies found!")

conn.close()
