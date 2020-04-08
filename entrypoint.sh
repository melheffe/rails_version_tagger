#!/bin/bash

function get_latest_tag {
  latest_tag=$(git tag | tail -1)
}

function get_current_info {
  current_branch=$(git rev-parse --abbrev-ref HEAD)
}

function prepare_file_info {
  version_on_file=$(cut -d " " -f 1 VERSION)
  if [[ $version_on_file == v* ]]; then version_on_file="$(echo $version_on_file | cut -c2-)"; fi
}

function prepare_github_info {
  remote=$(git config --get remote.origin.url)
  repo=$(basename $remote .git)
}

function set_release_notes {
  release_notes=$(git log $latest_tag..HEAD --oneline --merges)
  # Checking if the release notes are empty to get individual commits instead
  if [ -z $release_notes ]; then release_notes=$(git log $latest_tag..HEAD --oneline); fi

}

function create_git_tag_and_release {
  curl --data  '{"tag_name": "'"$PREPEND$version_on_file$APPEND"'","target_commitish": "'"$current_branch"'","name": "'"Release $version_on_file"'","body": "'"Release $version_on_file"'","draft": "'"$DRAFT"'","prerelease": "'"$PRERELEASE"'"}' https://api.github.com/repos/$REPO_OWNER/$repo/releases?access_token=$TOKEN
}

cd $GITHUB_WORKSPACE/

ls -al

echo "------------- Script Starting ----------------------"

git fetch --prune-tags

files=$(git diff --name-status $latest_tag HEAD | grep 'VERSION')

echo $files

if [ -z "$files" ];
then
  echo "Nothing to tag!";
  exit $?
else
  echo "Verison File has been updated, proceeding to tag"
  prepare_file_info
  prepare_github_info
  create_git_tag_and_release
  echo $release_notes
  exit $?
fi
echo "------------- Script Ending ----------------------"