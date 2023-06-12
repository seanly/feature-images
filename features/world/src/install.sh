#!/bin/bash

_FEATURE_HELLO_HELLO="${__FEATURE_HELLO_HELLO__:-imgutils}"
echo "hello, ${_FEATURE_HELLO_HELLO}" > /opt/world

cp -r ${__FEATURE_PATH__:-/tmp/build-src}/run.sh /run.sh

chmod 750 /run.sh