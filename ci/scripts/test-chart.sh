#!/bin/bash

set -eux

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
cd $ROOT

helm lint helm/*/

helm template helm/update-all-cf-buildpacks -n ""
