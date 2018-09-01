#!/bin/bash -

cd /ethereum/api-dev
rm -r public
cp -par contracts public/
cd public

git remote rename origin upstream
git remote add origin git@github.com:smart-mining/ethereum-contracts.git
git config user.name "rapsta"
git config user.email "info@x0e.de"
#git config user.email "mail@icemine.io"
git checkout --orphan latest_branch
git reset --hard

cp -par ../contracts/* .
cp -par ../contracts/.gitattributes .
cp -par ../contracts/.gitmodules .

#git checkout --
git add .git*
git add Ice*
git add -A github.com
git commit -m "The future of cryptocurrency mining as a reliable, secure and transparent platform."
git branch -D master
git branch -m master
git push -f origin master


