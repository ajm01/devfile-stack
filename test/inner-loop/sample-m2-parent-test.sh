#!/bin/bash

# Mvn repository volume and parent devfile config inner loop test using the application-stack-intro application.
echo -e "\n> Mvn repository volume and parent devfile config inner loop test"

# Base work directory.
BASE_DIR=$(pwd)

# Build type sub-path to the wlp installation.
BUILD_WLP_SUB_PATH=target/liberty

mkdir inner-loop-test-dir
cd inner-loop-test-dir

echo -e "\n> Clone application-stack-samples project"
git clone https://github.com/OpenLiberty/application-stack-samples.git

echo -e "\n> Clone application-stack-intro project"
git clone https://github.com/OpenLiberty/application-stack-intro.git
cd application-stack-intro

echo -e "\n> Copy the m2 sample devfile and update the stack image with the one built"
cp ../application-stack-samples/devfiles/m2-repo-volume/devfile.yaml devfile.yaml
sed -i '/container:/a\ \ \ \ \ \ \ \ image: localhost:5000/test-image-maven' devfile.yaml

# this is a workaround to avoid surefire fork failures when running
# the GHA test suite.
# Issue #138 has been opened to track and address this
# add the -DforkCount arg to the odo test cmd only for this run
echo -e "\n> Modifying the odo test command"
sed -i 's/failsafe:integration-test/-DforkCount=0 failsafe:integration-test/' devfile.yaml

echo -e "\n Updated devfile contents:"
cat devfile.yaml

echo -e "\n> Base Inner loop test run"
BASE_WORK_DIR=$BASE_DIR \
COMP_NAME=my-ol-component \
PROJ_NAME=inner-loop-test \
LIBERTY_SERVER_LOGS_DIR_PATH=/projects/$BUILD_WLP_SUB_PATH/wlp/usr/servers/defaultServer/logs \
$BASE_DIR/test/inner-loop/base-inner-loop.sh

rc=$?
if [ $rc -ne 0 ]; then
    exit 12
fi

echo -e "\n> Cleanup: Delete created directories"
cd $BASE_DIR; rm -rf inner-loop-test-dir