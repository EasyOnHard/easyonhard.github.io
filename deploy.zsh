#!/bin/zsh
set -e

echo "Syncing content..."
cd ~/Documents/Hugo-Obsidian-Site/blog/
rm -rf content/Wiki
rsync -av --delete --exclude="Wiki.md" ~/Documents/Notes/Wiki/ ~/Documents/Hugo-Obsidian-Site/blog/content/Wiki/

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
