#!/bin/bash

# The goal of this script is to bump the current project version

# Final values
bumpingToVersionNumber=
bumpingToBuildNumber=

# Current values
versionNumber=$(git for-each-ref --sort='-authordate' | grep '.*refs/remotes/origin/delivery/bump-' | head -1 | rev | cut -d'-' -f 1-2 | rev | cut -d'-' -f 1)
buildNumber=$(git for-each-ref --sort='-authordate' | grep '.*refs/remotes/origin/delivery/bump-' | head -1 | rev | cut -d'-' -f 1-2 | rev | cut -d'-' -f 2)


# Ensure it's run from the correct path
# Falls back to exiting in case it is not executed from the correct path
check_script_execution_path() {

  plist="Client/Info.plist"
  if [ ! -f "$plist" ]; then
    echo "[x] Please run this script from the root of the project with ./bump.sh"
    exit 0
  fi
}

# Checks whether the git status is clean.
# Proceeds in case it is clean.
# Asks to stash all in case it is not.
# Falls back to exiting in case the user says he does not want to stash.
git_clean_or_stash() {

  if [ -z "$(git status --porcelain)" ]; then
    echo "[i] Git status clean, proceeding"
  else
    echo "[x] Git status not clean, shall we stash? [Yy/Nn]"
    stash=
    while [[ $stash = "" ]]; do
      read stash
      if [ "$stash" = "Y" ] || [ "$stash" = "y" ]; then
        echo "[v] Stashing..."
        git stash -u
      else
        echo "[v] Ok bye."
        exit 0
      fi
    done
  fi
}

# Perform a quick bump, with calculated values.
# Infinite user input loop until anything is typed.
# Falls back to interactive bump in case the user says he does not want to do a quick bump.
quick_bump() {

  incrementedBuildNumber=$((buildNumber+1))
  echo "[?] Do you want to bump from $versionNumber($buildNumber) to $versionNumber($incrementedBuildNumber)? [Yy/Nn]"
  quickBump=
  while [[ $quickBump = "" ]]; do
    read quickBump
  done

  if [ "$quickBump" = "Y" ] || [ "$quickBump" = "y" ]; then
    bumpingToVersionNumber=$versionNumber
    bumpingToBuildNumber=$incrementedBuildNumber
    echo "[v] Bumping to $versionNumber($incrementedBuildNumber)!"
  else
    interactive_bump
  fi
}

# Perform an interactive bump, allows to input custom values.
# Infinite user input loops until a correct value is typed.
# Falls back to exiting in case the user says he does not want to do an interactive bump.
interactive_bump() {

  echo "[?] The version number is $versionNumber, what is the new value? [xxx.yy.zz]"
  interactiveVersionNumber=
  while [[ $interactiveVersionNumber = "" ]]; do
    read interactiveVersionNumber
    if [[ ! $interactiveVersionNumber =~ ^[0-9]+(\.[0-9]+){2}$ ]]; then
      echo "[x] Wrong format. Try again. [xxx.yy.zz]"
      interactiveVersionNumber=
    fi
  done

  echo "[?] The build number is $buildNumber, what is the new value? [v]"
  interactiveBuildNumber=
  while [[ $interactiveBuildNumber = "" ]]; do
    read interactiveBuildNumber
    if [[ ! $interactiveBuildNumber =~ ^[0-9]+$ ]]; then
      echo "[x] Wrong format. Try again. [v]"
      interactiveBuildNumber=
    fi
  done

  echo "[?] Do you want to bump from $versionNumber($buildNumber) to $interactiveVersionNumber($interactiveBuildNumber)? [Yy/Nn]"
  bump=
  while [[ $bump = "" ]]; do
    read bump
  done

  if [ "$bump" = "Y" ] || [ "$bump" = "y" ]; then
    bumpingToVersionNumber=$interactiveVersionNumber
    bumpingToBuildNumber=$interactiveBuildNumber
    echo "[v] Bumping to $interactiveVersionNumber($interactiveBuildNumber)!"
  else
    echo "[v] Ok bye."
    exit 0
  fi
}

# Determine the base branch to bump from. 
# Infinite user input loop until a correct value is typed.
define_bump_base_branch() {

  echo "[?] From which base branch? [1/2/3]"
  echo "1. $(git rev-parse --abbrev-ref HEAD) [current branch]"
  echo "2. qwant-develop"
  echo "3. qwant-main"
  baseBranch=
  baseBranchOption=
  while [[ $baseBranchOption = "" ]]; do
    read baseBranchOption
    if [ "$baseBranchOption" = "1" ]; then
      baseBranch=
    elif [ "$baseBranchOption" = "2" ]; then
      baseBranch="qwant-develop"
    elif [ "$baseBranchOption" = "3" ]; then
      baseBranch="qwant-main"
    else
      echo "[x] Wrong format. Try again. [1/2/3]"
      baseBranchOption=
    fi
  done
}

# Creates the bump branch
# Sets the correct agv version
# Commit and push
bump_and_push() {

  branchName="delivery/bump-$bumpingToVersionNumber-$bumpingToBuildNumber"
  if [ ! -z "$baseBranch" ]; then
    git checkout $baseBranch
    git pull
  fi
  git checkout -b "$branchName"
  agvtool new-marketing-version $bumpingToVersionNumber
  agvtool new-version -all $bumpingToBuildNumber
  git add *
  git commit -m "[Qwant] Bump version to $bumpingToVersionNumber-$bumpingToBuildNumber"
  git push origin -u "$branchName"
}

# Script start

clear
check_script_execution_path
git_clean_or_stash
quick_bump
define_bump_base_branch
bump_and_push

echo "[v] All done, bye!"

# Script end