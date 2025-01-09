#!/usr/bin/env bash

set -eu

for type in inFlows outFlows controls controlledBy siblingUsage; do
    ./train_glove.sh corpus/$type.txt models/$type
done
