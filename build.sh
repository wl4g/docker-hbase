#!/bin/bash
# Copyright 2017 ~ 2025 the original authors <jameswong1376@gmail.com>. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e

export BASE_DIR=$(cd "`dirname $0`"/; pwd)
export HBASE_VERSION="2.1.0"
export SHORT_PHOENIX_VERSION="5.1.1"
export LONG_PHOENIX_VERSION="hbase-2.1-${SHORT_PHOENIX_VERSION}"
export BUILD_IMAGE_VERSION="hbase-${HBASE_VERSION}-phoenix-${SHORT_PHOENIX_VERSION}"

function print_help() {
  echo $"
Usage: ./$(basename $0) [OPTIONS] [arg1] [arg2] ...
    build              Build of hbase image.
    push               Push the hbase image to repoistory.
          <repo_uri>   Push to repoistory uri. format: <registryUri>/<namespace>, e.g: registry.cn-shenzhen.aliyuncs.com/wl4g-k8s
"
}

function build_images() {
  local hbaseDir="${BASE_DIR}/materials/hbase-${HBASE_VERSION}"
  echo "Checking ${hbaseDir} ..."
  if [ ! -d "${hbaseDir}" ]; then
    local hbaseTarFile="${BASE_DIR}/materials/hbase-${HBASE_VERSION}-bin.tar.gz"
    echo "Checking ${hbaseTarFile} ..."
    if [ ! -f "$hbaseTarFile" ]; then
      echo "Downloading HBase tar ..."
      cd ${BASE_DIR}/materials/ && curl -OL "https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz"
    fi
    echo "Unpacking hbase-${HBASE_VERSION}-bin.tar.gz ..."
    cd ${BASE_DIR}/materials/ && tar -xvf hbase-${HBASE_VERSION}-bin.tar.gz
  fi

  local phoenixDir="${BASE_DIR}/materials/phoenix-${LONG_PHOENIX_VERSION}-bin"
  echo "Checking ${phoenixDir} ..."
  if [ ! -d "${phoenixDir}" ]; then
    local phoenixTarFile="${BASE_DIR}/materials/phoenix-${LONG_PHOENIX_VERSION}-bin.tar.gz"
    echo "Checking ${phoenixTarFile} ..."
    if [ ! -f "$phoenixTarFile" ]; then
        echo "Downloading phoenix-${LONG_PHOENIX_VERSION}-bin.tar.gz ..."
        cd ${BASE_DIR}/materials/ && curl -OL "http://archive.apache.org/dist/phoenix/phoenix-${SHORT_PHOENIX_VERSION}/phoenix-${LONG_PHOENIX_VERSION}-bin.tar.gz"
    fi
    echo "Unpacking phoenix-${LONG_PHOENIX_VERSION}-bin.tar.gz ..."
    cd ${BASE_DIR}/materials/ && tar -xvf phoenix-${LONG_PHOENIX_VERSION}-bin.tar.gz
  fi

  # Add hbase-site.xml configure
  cp ${BASE_DIR}/hbase-site.xml $hbaseDir/conf/
  cp ${BASE_DIR}/hbase-site.xml $phoenixDir/bin/

  # Notice: Use link in Dockerfile.
  # echo "Copying phoenix-${LONG_PHOENIX_VERSION}-bin/phoenix-server-${LONG_PHOENIX_VERSION}.jar to hbase-${HBASE_VERSION}/lib/ ..."
  # cd ${BASE_DIR}/materials/ && cp phoenix-${LONG_PHOENIX_VERSION}-bin/phoenix-server-${LONG_PHOENIX_VERSION}.jar hbase-${HBASE_VERSION}/lib/

  echo "Building ${BUILD_IMAGE_VERSION} images ..."
  cd $BASE_DIR && docker build -t wl4g/hbase:${BUILD_IMAGE_VERSION} . &

  wait
}

function push_images() {
  local repo_uri="$1"
  [ -z "$repo_uri" ] && repo_uri="docker.io/wl4g"
  ## FIX: Clean up suffix delimiters for normalization '/'
  repo_uri="$(echo $repo_uri | sed -E 's|/$||g')"

  echo "Tagging images to $repo_uri ..."
  docker tag wl4g/hbase:${BUILD_IMAGE_VERSION} $repo_uri/hbase:${BUILD_IMAGE_VERSION}
  docker tag wl4g/hbase:${BUILD_IMAGE_VERSION} $repo_uri/hbase:latest

  echo "Pushing images of ${BUILD_IMAGE_VERSION}@$repo_uri ..."
  docker push $repo_uri/hbase:${BUILD_IMAGE_VERSION} &

  echo "Pushing images of latest@$repo_uri ..."
  docker push $repo_uri/hbase &

  wait
}

# --- Main. ---
case $1 in
  build)
    build_images
    ;;
  push)
    push_images "$2"
    ;;
  *)
    print_help
    ;;
esac
