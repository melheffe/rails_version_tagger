#!/bin/bash

function get_latest_tag {
  { latest_tag="$(git describe --abbrev=0 --tags)"; } 2>/dev/null
}

function get_current_info {
  { current_branch="$(git rev-parse --abbrev-ref HEAD)"; } 2>/dev/null
}

function prepare_file_info {
  { version_on_file="$(cut -d " " -f 1 VERSION)"; } 2>/dev/null
  if [[ $version_on_file == v* ]]; then version_on_file="$(echo $version_on_file | cut -c2-)"; fi
}

function prepare_github_info {
  { remote="$(git config --get remote.origin.url)";} 2>/dev/null
  { repo="$(basename $remote .git)";} 2>/dev/null
  { latest_tag="$(git describe --abbrev=0 --tags)"; } 2>/dev/null
}

function set_release_notes {
  { release_notes="$(git log $latest_tag..HEAD --oneline --merges)"; } 2>/dev/null
  # Checking if the release notes are empty to get individual commits instead
  if [ -z $release_notes ]; then { release_notes="$(git log $latest_tag..HEAD --oneline)"; } 2>/dev/null; fi

}

function create_git_tag_and_release {
  curl --data  '{"tag_name": "'"$PREPEND$version_on_file$APPEND"'","target_commitish": "'"$current_branch"'","name": "'"Release $version_on_file"'","body": "'"Release $version_on_file"'","draft": "'"$DRAFT"'","prerelease": "'"$PRERELEASE"'"}' https://api.github.com/repos/$REPO_OWNER/$repo/releases?access_token=$TOKEN
}

files=$(git diff --name-status $latest_tag HEAD | grep 'VERSION')

if [ -z "$files" ];
then
  echo "Nothing to tag!";
  exit $?
else
  get_latest_tag
  prepare_file_info
  prepare_github_info
  create_git_tag_and_release
  echo $release_notes
  exit $?
fi