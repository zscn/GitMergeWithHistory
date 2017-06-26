#!/bin/bash

SCRIPTPATH=`dirname "$(cd ${0%/*} && echo $PWD/${0##*/})"`
echo $SCRIPTPATH
FolderRoot="/d/sourcecode/github"
TempFolder="/d/sourcecode/tmp"
RepoUrlBase="https://github.com/zscn/"
RepoFolderBase="/d/sourcecode/github/"

RepoAName="GitRepoA"
RepoBName="GitRepoB"
RepoCName="GitRepoC"

function CheckRepoExistence() {
	RepoUrl="$RepoUrlBase$1.git"
	RepoHead=`git ls-remote $RepoUrl HEAD`
	if [ -z ${RepoHead+x} ]; then
	    echo "$RepoUrl is not exist";
	    exit;
	fi
	echo "Found the repo: $RepoUrl'"; 
}

function CheckIfCurrentGitStatusIsClean() {
	GitStatus=`git ls-files --other --exclude-standard --directory | egrep -v '/$'`
	if [ ! -z $GitStatus]; then
		echo "Seems git status is not clean in current folder";
		exit;
	fi
}

function ImportRepo() {
	echo "Start to import repo $1 to parent repo $2"
	echo ""
	ImportRepoUrl="$RepoUrlBase$1.git"
	ParentUrl="$RepoUrlBase$2.git"
	ParentRepoFolder="$RepoFolderBase$2"


	if [ ! -d $ParentRepoFolder ]; then
		echo "unable to find the parent repo folder: $ParentRepoFolder";
		exit;
	fi

	cd $ParentRepoFolder
	CheckIfCurrentGitStatusIsClean
	git checkout master
	git fetch
	git rebase origin/master
	if [ ! `git branch --list clean` ]; then
		echo "git branch clean" && echo "" && git branch clean
	fi
	git checkout clean
	git reset --hard origin/clean
	git remote add $1 $ImportRepoUrl
	git fetch --all	
	git checkout -t -b $1 $1/master
	mkdir $1
	git mv -k * ./$1
	git commit -m "Added repo $1"
	git checkout master
	git merge $1 master
	git remote remove $1
	git push -u origin master
}

STARTTIME=$(date +%s)
echo "Started at: $STARTTIME"
echo ""

CheckRepoExistence $RepoAName
CheckRepoExistence $RepoBName
CheckRepoExistence $RepoCName

ImportRepo $RepoAName $RepoCName
ImportRepo $RepoBName $RepoCName

ENDTIME=$(date +%s) 
echo "Finished at:" $(date +"%Y-%m-%d %T")", Elapsed Time: "$(($ENDTIME - $STARTTIME))" seconds"
echo ""