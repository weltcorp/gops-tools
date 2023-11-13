#!/bin/bash

if which mockery >/dev/null; then
  echo "mockery already installed"
else
  brew install mockery
fi

for moduleDir in modules/*; do
    if [ -d "$moduleDir" ]; then
        for domainDir in "$moduleDir"/domain*; do
            if [ -d "$domainDir" ]; then
                cd "$domainDir"

                mockery --all
                if [ -d "mocks" ]; then
                    if [ -d "../mocks" ]; then
                        rm -rf "../mocks"
                    fi
                    mv mocks ../
                fi

                cd - > /dev/null
            fi
        done
    fi
done