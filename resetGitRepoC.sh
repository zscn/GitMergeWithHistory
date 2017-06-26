#!/bin/bash

cd /d/sourcecode/github 
rm -rf GitRepoC 
mkdir GitRepoC 
cd GitRepoC 
git init 
touch .gitignore 
git add . 
git commit -am "initial commit" 
git remote add origin https://github.com/zscn/GitRepoC.git 
git push origin master -f 
git checkout -b clean 
git push origin clean:clean -f 
git checkout master