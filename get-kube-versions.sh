#!/bin/bash

# Get the list of Kubernetes versions from its Git repo, starting with version v1.0.0
git ls-remote --refs https://github.com/kubernetes/kubernetes.git | grep 'refs\/tags\/v' | awk -F 'refs/tags/' '{print $2}' | grep -v 'alpha\|beta\|dev\|rc\|v0' | sort --version-sort > kube-versions
