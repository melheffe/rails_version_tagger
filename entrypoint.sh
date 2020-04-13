#!/bin/bash

function get_latest_tag {
  latest_tag=$(git tag | tail -1)
  echo $latest_tag
}

function get_current_info {
  current_branch=$TRIGGER
  echo $current_branch
}

function prepare_file_info {
  version_on_file=$(cut -d " " -f 1 VERSION)
  if [[ $version_on_file == v* ]]; then version_on_file="$(echo $version_on_file | cut -c2-)"; fi
  echo $version_on_file
}

function prepare_github_info {
  remote=$(git config --get remote.origin.url)
  repo=$(basename $remote .git)
}

function set_release_notes {
  release_notes=$(git log $latest_tag..HEAD --merges --pretty=tformat:"%h %s")
  # Checking if the release notes are empty to get individual commits instead
  if [ -z $release_notes ]; then release_notes=$(git log $latest_tag..HEAD --pretty=tformat:"%h %s"); fi
  echo $release_notes
}

function create_git_tag_and_release {
  # POST a release to repo via Github API
  curl -s -X POST https://api.github.com/repos/$REPO_OWNER/$repo/releases \
  -H "Authorization: token $TOKEN" \
  -d @- << EOF
  {
  "tag_name": "$PREPEND$version_on_file$APPEND",
  "target_commitish": "$current_branch",
  "name": "Release $version_on_file",
  "body": "$release_notes",
  "draft": $DRAFT,
  "prerelease": $PRERELEASE
  }
EOF
}

cd $GITHUB_WORKSPACE/

echo "------------- Script Starting ----------------------"

git fetch --prune-tags

get_latest_tag

get_current_info

files=$(git diff --name-status $latest_tag HEAD | grep 'VERSION')

if [ -z "$files" ];
then
  echo "Nothing to tag!";
  exit $?
else
  echo "Version File has been updated, proceeding to tag"
  prepare_file_info
  prepare_github_info
  result=$(create_git_tag_and_release)
  echo $result | jq .url
  exit $?
fi
echo "------------- Script Ending ----------------------"
