#!/bin/bash -

cd /ethereum/api-dev
rm -r public
cp -par contracts public
cd public

git remote rename origin upstream
git remote add origin git@github.com:icemine-io/ethereum-contracts.git
git config icemine.io
git checkout --orphan latest_branch
git add -A
git commit -am "The future of cryptocurrency mining as a reliable, secure and transparent platform."
git branch -D master
git branch -m master
git push -f origin master


