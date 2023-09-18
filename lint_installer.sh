#!/bin/sh

install_bun() {
  if ! brew list | grep "^bun$"; then
    brew tap oven-sh/bun
    brew install bun
  fi
}

install_husky() {
  bun add -D husky @commitlint/config-conventional @commitlint/cli
  bun husky install

  if ! ls .husky | grep -q "^commit-msg$"; then
    bun husky add .husky/commit-msg "bun commitlint --edit \$1"
    setup_commit_msg_hook
  fi

  if ! cat .gitignore | grep -q "^node_modules$"; then
    echo "\nnode_modules" >> .gitignore
  fi

  if ! cat .dockerignore | grep -q "^node_modules$"; then
    echo "\nnode_modules" >> .dockerignore
  fi

  bun install
}

setup_commit_msg_hook() {
  cat << "EOF" >> .husky/commit-msg
COMMIT_EDITMSG=$1
BRANCH=""
ISSUE_NUMBER=""
extract_issue() {
  if [[ $BRANCH =~ [A-Z]+-[0-9]+ ]]; then
    ISSUE_NUMBER=${BASH_REMATCH[0]}
  elif [[ $BRANCH =~ ^([0-9]+)- ]]; then
    ISSUE_NUMBER="#${BASH_REMATCH[1]}"
  fi
}

BRANCH=$(git branch | grep '*' | sed 's/* //')
if [[ $BRANCH =~ v[0-9]+ ]]; then
  exit 0;
fi
extract_issue

echo "$(cat $COMMIT_EDITMSG) [$ISSUE_NUMBER]" > $COMMIT_EDITMSG
EOF
}

setup_commit_lint() {
  cat << "EOF" > commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
      'subject-case': [
          2,
          'always',
          [
            'lower-case',
            'upper-case',
            'camel-case',
            'kebab-case',
            'pascal-case',
            'sentence-case',
            'start-case',
          ]
      ],
      'subject-empty': [
          2,
          'never'
      ],
      'subject-full-stop': [
          2,
          'never',
          '.'
      ],
      'type-case': [
          2,
          'always',
          'lower-case'
      ],
      'type-empty': [
          2,
          'never'
      ],
      'type-enum': [
          2,
          'always',
          [
              'doc',
              'fix',
              'impl',
          ]
      ]
  }
};
EOF
}

install_bun
install_husky
setup_commit_lint
