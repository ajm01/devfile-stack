#!/bin/bash

# Outer loop test using the application-stack-intro application.
# The application image is built using the following arguments: 
# ADD_MP_HEALTH=false and ENABLE_OPENJ9_SCC=false
echo -e "\n> Docker build with MPH false SCC false args outer loop test"

# Base work directory.
BASE_DIR=$(pwd)

# Component name. 
MPHOFF_SCCOFF_COMP_NAME="dbuild-mphoff-sccoff"

mkdir outer-loop-mphOff-sccOff-test-dir
cd outer-loop-mphOff-sccOff-test-dir

echo -e "\n> Clone application-stack-intro project"
git clone https://github.com/OpenLiberty/application-stack-intro.git
cd application-stack-intro

echo -e "\n> Copy Dockerfile"
if [ "$1" = "gradle" ]; then
  cp $BASE_DIR/generated/outer-loop/gradle/Dockerfile Dockerfile
else
  cp $BASE_DIR/generated/outer-loop/maven/Dockerfile Dockerfile
fi

echo -e "\n> Copy app-deploy.yaml"
cp $BASE_DIR/templates/outer-loop/app-deploy.yaml app-deploy.yaml

echo -e "\n> Build Docker image"
sed -i '/COPY --from=compile/a RUN true' Dockerfile
docker build --build-arg ADD_MP_HEALTH=false --build-arg ENABLE_OPENJ9_SCC=false -t outerloop/application-stack-intro:1.0 .

echo -e "\n> Replace variables in app-deploy.yaml"
sed -i 's/{{\.PORT}}/9080/g' app-deploy.yaml
sed -i "s/{{\.COMPONENT_NAME}}/${MPHOFF_SCCOFF_COMP_NAME}/g" app-deploy.yaml
sed -i 's/{{\.CONTAINER_IMAGE}}/outerloop\/application-stack-intro:1\.0/g' app-deploy.yaml

echo -e "\n> Base outer loop test run"
BASE_WORK_DIR=$BASE_DIR COMP_NAME=${MPHOFF_SCCOFF_COMP_NAME} $BASE_DIR/test/outer-loop/base-outer-loop.sh
rc=$?
if [ $rc -ne 0 ]; then
    exit 12
fi

echo -e "\n> Cleanup: Delete created directories"
cd $BASE_DIR; rm -rf outer-loop-mphOff-sccOff-test-dir
