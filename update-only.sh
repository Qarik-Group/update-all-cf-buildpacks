#!/bin/bash

cf update-buildpack -s cflinuxfs3 --enable go_buildpack -p https://github.com/cloudfoundry/go-buildpack/releases/download/v1.9.0/go-buildpack-cflinuxfs3-v1.9.0.zip
