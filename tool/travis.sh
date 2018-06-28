#!/bin/bash

# Fast fail the script on failures.
set -xe

dartanalyzer --fatal-warnings .

pub run test -p vm -j 1
pub run test -p chrome -j 1
pub run build_runner test -- -p vm -j 1
pub run build_runner test -- -p chrome -j 1
# pub run test -p content-shell -j 1
# pub run test -p firefox -j 1

# test dartdevc support
pub run build_runner build example_todo