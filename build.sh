#!/bin/bash

if [ ! -e node_modules ]
then
  mkdir node_modules
fi

case `uname -s` in
  MINGW*)
    USER_UID=1000
    GROUP_UID=1000
    ;;
  *)
    if [ -z ${USER_UID:+x} ]
    then
      USER_UID=`id -u`
      GROUP_GID=`id -g`
    fi
esac

if [ -e "?/.gradle" ] && [ ! -e "?/.gradle/gradle.properties" ]
then
  echo "odeUsername=$NEXUS_ODE_USERNAME" > "?/.gradle/gradle.properties"
  echo "odePassword=$NEXUS_ODE_PASSWORD" >> "?/.gradle/gradle.properties"
  echo "sonatypeUsername=$NEXUS_SONATYPE_USERNAME" >> "?/.gradle/gradle.properties"
  echo "sonatypePassword=$NEXUS_SONATYPE_PASSWORD" >> "?/.gradle/gradle.properties"
fi

clean () {
  rm -rf node_modules
  rm -rf dist
}

init () {
  echo "[init] Get branch name from jenkins env..."
  BRANCH_NAME=`echo $GIT_BRANCH | sed -e "s|origin/||g"`
  if [ "$BRANCH_NAME" = "" ]; then
    echo "[init] Get branch name from git..."
    BRANCH_NAME=`git branch | sed -n -e "s/^\* \(.*\)/\1/p"`
  fi
  docker-compose run -e BRANCH_NAME=$BRANCH_NAME -e FRONT_TAG=$FRONT_TAG -e NEXUS_ODE_USERNAME=$NEXUS_ODE_USERNAME -e NEXUS_ODE_PASSWORD=$NEXUS_ODE_PASSWORD --rm -u "$USER_UID:$GROUP_GID" gradle sh -c "gradle generateTemplate"
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "npm rebuild node-sass --no-bin-links && npm install"
}

build () {
  local extras=$1
  dirs=($(ls -d ./skins/*))
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "npm run release:prepare"
  for dir in "${dirs[@]}"; do
    tmp=`echo $dir | sed 's/.\/skins\///'`
    docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "SKIN=$tmp npm run sass:build:release"
  done
  cp node_modules/ode-bootstrap/version.txt dist/version.txt
  VERSION=`grep "version="  gradle.properties| sed 's/version=//g'`
  echo "ode-bootstrap-neo=$VERSION `date +'%d/%m/%Y %H:%M:%S'`" >> dist/version.txt
}

watch () {
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "npm run dev:watch"
}

publishNPM () {
  LOCAL_BRANCH=`echo $GIT_BRANCH | sed -e "s|origin/||g"`
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "npm publish --tag $LOCAL_BRANCH"
}

publishNexus () {
  if [ -e "?/.gradle" ] && [ ! -e "?/.gradle/gradle.properties" ]
  then
    echo "odeUsername=$NEXUS_ODE_USERNAME" > "?/.gradle/gradle.properties"
    echo "odePassword=$NEXUS_ODE_PASSWORD" >> "?/.gradle/gradle.properties"
    echo "sonatypeUsername=$NEXUS_SONATYPE_USERNAME" >> "?/.gradle/gradle.properties"
    echo "sonatypePassword=$NEXUS_SONATYPE_PASSWORD" >> "?/.gradle/gradle.properties"
  fi
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" gradle sh -c "gradle deploymentJar fatJar publish"
}

publishMavenLocal(){
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" gradle sh -c "gradle deploymentJar fatJar publishToMavenLocal"
}

for param in "$@"
do
  case $param in
    clean)
      clean
      ;;
    init)
      init
      ;;
    build)
      build
      ;;
    install)
      build && publishMavenLocal
      ;;
    watch)
      watch
      ;;
    publishNPM)
      publishNPM
      ;;
    publishNexus)
      publishNexus
      ;;
    *)
      echo "Invalid argument : $param"
  esac
  if [ ! $? -eq 0 ]; then
    exit 1
  fi
done