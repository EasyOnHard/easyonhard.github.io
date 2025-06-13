#!/bin/zsh
set -e

echo "Syncing content..."
cd ~/Documents/Hugo-Obsidian-Site/blog2/
rm -rf content/Wiki
rm -rf content/Minecraft
rsync -av --exclude="Wiki.md" ~/Documents/Notes/Hugo\ Site/ ~/Documents/Hugo-Obsidian-Site/blog2/content/

echo "Building site..."
hugo

echo "Committing changes..."
if ! git diff --quiet; then
  git add .
  git commit -m "Collecting all Files"
fi

echo "Deploying to gh-pages..."
git subtree split --prefix=public -b temp-deploy
git push --force origin temp-deploy:gh-pages
git branch -D temp-deploy

echo "Deployed to GitHub Pages!"
