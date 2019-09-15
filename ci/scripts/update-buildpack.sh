#!/bin/bash

set -eu

: ${GITHUB_ORG:=cloudfoundry}
: ${GITHUB_REPO:?required}
: ${BUILDPACK_NAME:?required}

version=$(cat $GITHUB_REPO/version)
filename=$(basename $(ls $GITHUB_REPO/*.zip))

git clone git pushme
cd pushme

sed -i "s%.*\"$BUILDPACK_NAME\".*$%  \"$BUILDPACK_NAME\": \"https://github.com/$GITHUB_ORG/$GITHUB_REPO/releases/download/v${version}/${filename}\",%" buildpacks.json
sed -i "s%.*\"$BUILDPACK_NAME\".*$%  \"$BUILDPACK_NAME\": \"https://github.com/$GITHUB_ORG/$GITHUB_REPO/releases/download/v${version}/${filename}\",%" update-only.sh

if [[ "$(git status -s)X" != "X" ]]; then
  if [[ -z $(git config --global user.email) ]]; then
    git config --global user.email "drnic+bot@starkandwayne.com"
  fi
  if [[ -z $(git config --global user.name) ]]; then
    git config --global user.name "CI Bot"
  fi
  git add buildpacks.json
  git add update-only.sh
  git commit -m "Updated $BUILDPACK_NAME to v${version}"
fi
