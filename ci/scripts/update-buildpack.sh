#!/bin/bash

set -eu

: ${GITHUB_ORG:=cloudfoundry}
: ${GITHUB_REPO:?required}
: ${BUILDPACK_NAME:?required}

version=$(cat $GITHUB_REPO/version)
filename=$(basename $(ls $GITHUB_REPO/*.zip))

git clone git pushme
cd pushme
cat > update-only.sh <<SHELL
#!/bin/bash

cf update-buildpack -s cflinuxfs3 --enable $BUILDPACK_NAME -p https://github.com/$GITHUB_ORG/$GITHUB_REPO/releases/download/v${version}/${filename}
SHELL
if [[ "$(git status -s)X" != "X" ]]; then
  if [[ -z $(git config --global user.email) ]]; then
    git config --global user.email "drnic+bot@starkandwayne.com"
  fi
  if [[ -z $(git config --global user.name) ]]; then
    git config --global user.name "CI Bot"
  fi
  git add update-only.sh
  git commit -m "Updated $BUILDPACK_NAME to v${version}"
fi
