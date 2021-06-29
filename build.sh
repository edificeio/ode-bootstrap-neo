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
  #dont need to exec twice
  if [ "$FIRST_TIME" = "false" ]; then
    return 0
  fi
  rm -rf node_modules
  rm -rf dist
  rm -rf build
  rm -rf build-css
  rm -rf deployment/*
}

init () {
  echo "[init] Get branch name from jenkins env..."
  BRANCH_NAME=`echo $GIT_BRANCH | sed -e "s|origin/||g"`
  if [ "$BRANCH_NAME" = "" ]; then
    echo "[init] Get branch name from git..."
    BRANCH_NAME=`git branch | sed -n -e "s/^\* \(.*\)/\1/p"`
  fi
  docker-compose run -e OVERRIDE_DIST=$OVERRIDE_DIST -e OVERRIDE_NAME=$OVERRIDE_NAME -e OVERRIDE_MODNAME=$OVERRIDE_MODNAME -e BRANCH_NAME=$BRANCH_NAME -e FRONT_TAG=$FRONT_TAG -e NEXUS_ODE_USERNAME=$NEXUS_ODE_USERNAME -e NEXUS_ODE_PASSWORD=$NEXUS_ODE_PASSWORD --rm -u "$USER_UID:$GROUP_GID" gradle sh -c "gradle generateTemplate"
  #dont need to exec twice
  if [ "$FIRST_TIME" = "false" ]; then
    return 0
  fi
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "npm rebuild node-sass --no-bin-links && npm install"
}

build () {
  local extras=$1
  #get skins
  dirs=($(ls -d ./skins/*))
  #create build dir var
  SCSS_DIR=$OVERRIDE_BUILD/scss
  SKIN_DIR=$OVERRIDE_BUILD/skins
  #create build dir and copy source
  mkdir -p $OVERRIDE_BUILD
  cp -R skins $SKIN_DIR
  cp -R scss $SCSS_DIR
  cp -R scss/$OVERRIDE_SRC/* $OVERRIDE_BUILD/scss/
  docker-compose run -e SKIN_DIR=$SKIN_DIR -e SCSS_DIR=$SCSS_DIR -e DIST_DIR=$OVERRIDE_DIST --rm -u "$USER_UID:$GROUP_GID" node sh -c "npm run release:prepare"
  for dir in "${dirs[@]}"; do
    tmp=`echo $dir | sed 's/.\/skins\///'`
    docker-compose run -e SKIN_DIR=$SKIN_DIR -e SCSS_DIR=$SCSS_DIR -e DIST_DIR=$OVERRIDE_DIST -e SKIN=$tmp  --rm -u "$USER_UID:$GROUP_GID" node sh -c "npm run sass:build:release"
  done
  cp node_modules/ode-bootstrap/version.txt $OVERRIDE_DIST/version.txt
  VERSION=`grep "version="  gradle.properties| sed 's/version=//g'`
  echo "ode-bootstrap-neo=$VERSION `date +'%d/%m/%Y %H:%M:%S'`" >> $OVERRIDE_DIST/version.txt
}

watch () {
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "npm run dev:watch"
}

publishNPM () {
  #dont need to exec twice
  if [ "$FIRST_TIME" = "false" ]; then
    return 0
  fi
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
  docker-compose run -e OVERRIDE_NAME=$OVERRIDE_NAME -e OVERRIDE_MODNAME=$OVERRIDE_MODNAME -e OVERRIDE_DIST=$OVERRIDE_DIST --rm -u "$USER_UID:$GROUP_GID" gradle sh -c "gradle deploymentJar fatJar publish"
}

publishMavenLocal(){
  docker-compose run -e OVERRIDE_NAME=$OVERRIDE_NAME -e OVERRIDE_MODNAME=$OVERRIDE_MODNAME  -e OVERRIDE_DIST=$OVERRIDE_DIST --rm -u "$USER_UID:$GROUP_GID" gradle sh -c "gradle deploymentJar fatJar publishToMavenLocal"
}


for param in "$@"
do
  export FIRST_TIME=true
  names=($(ls -d ./scss/overrides/*))
  for dirtyName in "${names[@]}"; do
    name=`echo $dirtyName | sed 's/.\/scss\/overrides\///'`
    MOD_NAME=`grep "modname="  gradle.properties| sed 's/modname=//g'`
    export OVERRIDE_NAME="$name"
    export OVERRIDE_SRC="overrides/$name"
    export OVERRIDE_DIST="dist/$name"
    export OVERRIDE_DIST_WILDCARD="dist/$name/**"
    export OVERRIDE_BUILD="build-css/$name"
    export OVERRIDE_MODNAME="$MOD_NAME-$name"
    #default does not have suffix on name
    if [ "$name" = "default" ]; then
      export OVERRIDE_MODNAME="$MOD_NAME"
    fi
    echo "[$param][$name] Starting..."
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
      publishMavenLocal)
        publishMavenLocal
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
    export FIRST_TIME=false
  done
done