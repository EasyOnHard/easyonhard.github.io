#!/bin/zsh

rsync -av --delete ~/Documents/Notes/Wiki ~/Documents/Hugo-Obsidian-Site/blog/content/

cd ~/Documents/Hugo-Obsidian-Site/blog/
hugo
git add .
git commit -m "Collecting all Files"
git push origin main
git subtree split --prefix=public -b deploy
git checkout deploy
git commit -m "Updating Pages with New Content"
git push --force origin deploy:gh-pages
git checkout main

echo "Should have Deployed!"
