#!/usr/bin/env bash

set -eu

flow_types=("inFlows" "outFlows" "controls" "controlledBy" "siblingUsage")
vector_sizes_small=(20 20 20 20 20)
vector_sizes_large=(150 150 150 150 168)

mkdir -p models-20
mkdir -p models-150

for i in "${!flow_types[@]}"; do
    ./train_glove.sh corpus/${flow_types[i]}.txt models-20/${flow_types[i]} ${vector_sizes_small[i]}
    ./train_glove.sh corpus/${flow_types[i]}.txt models-150/${flow_types[i]} ${vector_sizes_large[i]}
done
