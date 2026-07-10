#!/usr/bin/env bash

set -e

# scripts/build.sh
# : Perform necessary steps to build SDDM


echo -e "Step 1..."
cmake -B build -G Ninja -DCMAKE_POLICY_VERSION_MINIMUM=3.5

echo -e "Step 2..."
cmake --build build

echo -e "Step 3..."
ctest --test-dir build
