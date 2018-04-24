#!/bin/bash

readonly MATCHER=${2:-"*"}
readonly NPM_TAG=${3:-"beta"}

readonly NPM_NAME=$(node tools/attribute.js name)
readonly VERSION=$(node tools/attribute.js version)

readonly NPM_EXISTS=$(npm info -s $NPM_NAME@$1 version)

readonly NPM_BIN=$(npm bin)
readonly STABLE=$($NPM_BIN/semver $VERSION -r "*")

# Enable failing on exit status here because semver exits with 1 when the range
# doesn't match.
set -e

verbose()
{
  echo -e " \033[36m→\033[0m $1"
}

success()
{
  echo -e " \033[1;32m✔︎\033[0m $1"
}

publish()
{
  local version=$1; shift
  local npm_name=$1; shift
  local npm_tag=$1; shift

  local deploy_message="Deploying ${version} to npm"

  if [[ -n "$npm_tag" ]]; then
    verbose "${deploy_message} with tag ${npm_tag}"
    npm publish --tag "$npm_tag"
  else
    verbose "$deploy_message"
    npm publish
  fi

  success "${npm_name} uploaded to npm registry"
}

verbose "Checking if version ${VERSION} of ${NPM_NAME} is already available in npm…"

if [ -n "$NPM_EXISTS" ] && [ "$NPM_EXISTS" == "$VERSION" ]; then
  verbose "There is already a version ${NPM_EXISTS} in npm. Skipping npm publish…"
  exit 0
fi

if [ -z "$STABLE" ]; then
  publish "$VERSION" "$NPM_NAME" "$NPM_TAG"
  exit 0
fi

publish "$VERSION" "$NPM_NAME"
