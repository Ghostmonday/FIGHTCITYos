#!/bin/bash
# Git Authentication Setup Script for FightCityTickets

echo "🔐 Setting up Git authentication..."

# Set git user config (if not already set)
if [ -z "$(git config user.name)" ]; then
    echo "Setting git user name..."
    git config --global user.name "rentamac"
fi

if [ -z "$(git config user.email)" ]; then
    echo "Setting git user email..."
    git config --global user.email "rentamac@users.noreply.github.com"
fi

echo ""
echo "✅ Git user configured"
echo ""
echo "📋 Next steps:"
echo ""
echo "Option 1: Use Personal Access Token (Easiest)"
echo "1. Go to: https://github.com/settings/tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Select 'repo' scope"
echo "4. Copy the token"
echo "5. Run: git push"
echo "6. When prompted:"
echo "   - Username: your GitHub username"
echo "   - Password: paste the token (not your password!)"
echo ""
echo "Option 2: Use SSH (More secure)"
echo "1. Generate SSH key: ssh-keygen -t ed25519 -C 'your_email@example.com'"
echo "2. Add to GitHub: https://github.com/settings/keys"
echo "3. Change remote: git remote set-url origin git@github.com:Ghostmonday/FIGHTCITYos.git"
echo "4. Push: git push"
echo ""
echo "Current remote URL:"
git remote get-url origin
echo ""
echo "Ready to push! Run: git push"
