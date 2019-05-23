#!/bin/bash
# usage: ./release [major|minor|patch]
# works only for 'major.minor.patch' tag formats

CURRENT_TAG=$(git describe --tags --abbrev=0)

function release_major {
    echo "Doing a major release"
    MAJOR=$(($(cut -d'.' -f1 <<<$CURRENT_TAG)+1))
    MINOR=0
    PATCH=0
    NEXT_TAG="$MAJOR.$MINOR.$PATCH"
    release $NEXT_TAG
}

function release_minor {
    echo "Doing a minor release"
    MAJOR=$(cut -d'.' -f1 <<<$CURRENT_TAG)
    MINOR=$(($(cut -d'.' -f2 <<<$CURRENT_TAG)+1))
    PATCH=0
    NEXT_TAG="$MAJOR.$MINOR.$PATCH"
    release $NEXT_TAG
}

function release_patch {
    echo "Doing a patch release"
    MAJOR=$(cut -d'.' -f1 <<<$CURRENT_TAG)
    MINOR=$(cut -d'.' -f2 <<<$CURRENT_TAG)
    PATCH=$(($(cut -d'.' -f3 <<<$CURRENT_TAG)+1))
    NEXT_TAG="$MAJOR.$MINOR.$PATCH"
    release $NEXT_TAG
}

function release {

  update_chagelog $1
  commit_changelog_to_git $1
  create_git_tag $1
  push_to_git
}

function update_chagelog {
  echo "Update changelog"
  DATE=$(date +%F)
  sed -i.tmp 's/\#\# \[Unreleased\]/\#\# \[Unreleased\]\
\
\#\# \['$1'\] - '$DATE'/' CHANGELOG.md
  $(rm CHANGELOG.md.tmp)
}

function create_git_tag {
  echo "$(git tag $1)"

}

function commit_changelog_to_git {
  echo "$(git add CHANGELOG.md)"
  echo "$(git commit -m "Bump version to $1")"

}

function push_to_git {
  echo "$(git push origin master --tags)"
}

case $1 in
  "new")
    release '0.1.0'
    ;;
  "major")
    release_major
    ;;
  "minor")
    release_minor
    ;;
  "patch")
    release_patch
    ;;
  *)
    echo "Please inform the tag level release: 'major', 'minor' or 'patch'"
    echo "Or use 'new' to create a first tag"
    exit
    ;;
esac

