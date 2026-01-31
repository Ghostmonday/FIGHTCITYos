# Git Authentication Setup Guide

## Current Status
- ✅ Credential helper: `osxkeychain` (configured)
- ✅ Remote URL: `https://github.com/Ghostmonday/FIGHTCITYos.git`
- ⚠️ Authentication needed for push

## Option 1: Personal Access Token (Recommended for HTTPS)

### Steps:
1. Go to GitHub: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Set expiration and select scopes:
   - ✅ `repo` (Full control of private repositories)
4. Copy the token (you won't see it again!)

### Use the token:
When you push, Git will prompt for credentials:
- **Username:** Your GitHub username
- **Password:** Paste the Personal Access Token (not your GitHub password)

The token will be saved in macOS Keychain automatically.

### Test:
```bash
git push
# Enter username when prompted
# Enter token as password when prompted
```

---

## Option 2: SSH Authentication (Alternative)

### Steps:
1. Generate SSH key (if you don't have one):
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# Press Enter to accept default location
# Optionally set a passphrase
```

2. Add SSH key to ssh-agent:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

3. Copy public key:
```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

4. Add to GitHub:
   - Go to: https://github.com/settings/keys
   - Click "New SSH key"
   - Paste the key and save

5. Change remote to SSH:
```bash
git remote set-url origin git@github.com:Ghostmonday/FIGHTCITYos.git
```

6. Test:
```bash
ssh -T git@github.com
git push
```

---

## Option 3: GitHub CLI (gh)

### Install:
```bash
brew install gh
```

### Authenticate:
```bash
gh auth login
# Follow prompts:
# - GitHub.com
# - HTTPS
# - Login with web browser
```

### Push:
```bash
git push
```

---

## Quick Fix: Try Push Now

Since `osxkeychain` is configured, try pushing now. macOS will prompt you for credentials:

```bash
git push
```

If prompted:
- **Username:** Your GitHub username
- **Password:** Use a Personal Access Token (create one at https://github.com/settings/tokens)

The credentials will be saved in Keychain for future use.
