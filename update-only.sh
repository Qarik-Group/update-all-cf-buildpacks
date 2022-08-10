#!/bin/bash

set -eu

export TIMEOUT=${TIMEOUT:-3600}
export POLLING=${POLLING:-5}

[[ -n "${ROUTER_IP_ENVVAR:-}" && -n "${CF_SYSTEM_DOMAIN:-}" ]] && {
  echo "Setting up /etc/hosts to *.${CF_SYSTEM_DOMAIN}..."
  eval "export router_ip=\"\$$ROUTER_IP_ENVVAR\"" # works on alpine
  {
    echo "${router_ip}  login.${CF_SYSTEM_DOMAIN}"
    echo "${router_ip}  api.${CF_SYSTEM_DOMAIN}"
    echo "${router_ip}  uaa.${CF_SYSTEM_DOMAIN}"
  } >> /etc/hosts
}

cf target

# cf update-buildpack -s cflinuxfs3 --enable go_buildpack -p https://github.com/cloudfoundry/go-buildpack/releases/download/v1.9.0/go-buildpack-cflinuxfs3-v1.9.0.zip
# cf update-buildpack -s cflinuxfs3 --enable ruby_buildpack -p https://github.com/cloudfoundry/ruby-buildpack/releases/download/v1.7.43/ruby-buildpack-cflinuxfs3-v1.7.43.zip
# cf update-buildpack -s cflinuxfs3 --enable java_buildpack -p https://github.com/cloudfoundry/java-buildpack/releases/download/v4.21/java-buildpack-v4.21.zip
cflinuxfs3_buildpacks=$(cat <<-JSON
{
  "binary_buildpack": "https://github.com/cloudfoundry/binary-buildpack/releases/download/v1.0.45/binary-buildpack-cflinuxfs3-v1.0.45.zip",
  "dotnet_core_buildpack": "https://github.com/cloudfoundry/dotnet-core-buildpack/releases/download/v2.4.0/dotnet-core-buildpack-cflinuxfs3-v2.4.0.zip",
  "go_buildpack": "https://github.com/cloudfoundry/go-buildpack/releases/download/v1.9.48/go-buildpack-cflinuxfs3-v1.9.48.zip",
  "java_buildpack": "https://github.com/cloudfoundry/java-buildpack/releases/download/v4.50/java-buildpack-v4.50.zip",
  "nginx_buildpack": "https://github.com/cloudfoundry/nginx-buildpack/releases/download/v1.1.42/nginx-buildpack-cflinuxfs3-v1.1.42.zip",
  "nodejs_buildpack": "https://github.com/cloudfoundry/nodejs-buildpack/releases/download/v1.7.73/nodejs-buildpack-cflinuxfs3-v1.7.73.zip",
  "php_buildpack": "https://github.com/cloudfoundry/php-buildpack/releases/download/v4.4.64/php-buildpack-cflinuxfs3-v4.4.64.zip",
  "python_buildpack": "https://github.com/cloudfoundry/python-buildpack/releases/download/v1.7.57/python-buildpack-cflinuxfs3-v1.7.57.zip",
  "r_buildpack": "https://github.com/cloudfoundry/r-buildpack/releases/download/v1.1.32/r-buildpack-cflinuxfs3-v1.1.32.zip",
  "ruby_buildpack": "https://github.com/cloudfoundry/ruby-buildpack/releases/download/v1.8.57/ruby-buildpack-cflinuxfs3-v1.8.57.zip",
  "staticfile_buildpack": "https://github.com/cloudfoundry/staticfile-buildpack/releases/download/v1.5.33/staticfile-buildpack-cflinuxfs3-v1.5.33.zip",
  "ignore_me": "so all other items can end with comma"
}
JSON
)

function cfbuildpacks() {
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  if [[ -f $DIR/fixtures/cf-buildpacks.out ]]; then
    cat $DIR/fixtures/cf-buildpacks.out
  else
    cf buildpacks
  fi
}

echo "Checking for cflinuxfs3 updates..."
buildpack_names=$(echo "${cflinuxfs3_buildpacks}" | jq -r "keys | .[]")
for buildpack_name in $buildpack_names; do
  current_filename=$(cfbuildpacks | grep $buildpack_name | awk '{print $5}')
  if [[ -n $current_filename ]]; then
    new_buildpack_url=$(echo "$cflinuxfs3_buildpacks" | jq -r --arg buildpack_name $buildpack_name '.[$buildpack_name]')
    new_buildpack_filename=$(basename $new_buildpack_url)
    if [[ "$current_filename" != "$new_buildpack_filename" ]]; then
      echo "Updating $buildpack_name $current_filename -> $new_buildpack_filename"
      cf update-buildpack -s cflinuxfs3 --enable "$buildpack_name" -p "$new_buildpack_url"
    fi
  fi
done

echo "Success."