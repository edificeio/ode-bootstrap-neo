#!/bin/bash

if [ ! -e node_modules ]
then
  mkdir node_modules
fi

case `uname -s` in
  MINGW* | Darwin*)
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

# OVERRIDES VARS
OVERRIDE_NAME="default"
for i in "$@"
do
case $i in
  -o=*|--override=*)
  OVERRIDE_NAME="${i#*=}"
  shift
  ;;
  *)
  ;;
esac
done

MOD_NAME=ode-bootstrap-neo
if [ "$OVERRIDE_NAME" = "default" ];
then
  export FINAL_MODNAME="$MOD_NAME"
else
  export FINAL_MODNAME="$MOD_NAME-$OVERRIDE_NAME"
fi

export OVERRIDE_BUILD="build-css"
export OVERRIDE_DIST="dist"
export OVERRIDE_SRC="overrides/$OVERRIDE_NAME"
# end of OVERRIDES VARS

clean () {
  rm -rf node_modules
  rm -rf dist
  rm -rf build
  rm -rf build-css
  rm -f package.json
  rm -f yarn.lock
  rm -f pnpm-lock.yaml
  rm -rf deployment
}

doInit () {
  echo "[init$1][$OVERRIDE_NAME] Get branch name from jenkins env..."
  BRANCH_NAME=`echo $GIT_BRANCH | sed -e "s|origin/||g"`
  if [ "$BRANCH_NAME" = "" ]; then
    echo "[init$1][$OVERRIDE_NAME] Get branch name from git..."
    BRANCH_NAME=`git branch | sed -n -e "s/^\* \(.*\)/\1/p"`
  fi
  
  echo "[init$1][$OVERRIDE_NAME] Generate package.json from package.json.template..."
  NPM_VERSION_SUFFIX=`date +"%Y%m%d%H%M"`
  cp package.json.template package.json
  sed -i "s/%generateVersion%/${NPM_VERSION_SUFFIX}/" package.json
  sed -i "s/%branch%/${BRANCH_NAME}/" package.json

  if [ "$1" == "Dev" ]
  then
    sed -i "s/%odeBtVersion%/link:..\/ode-bootstrap\//" package.json
  else
    sed -i "s/%odeBtVersion%/${BRANCH_NAME}/" package.json
  fi

  echo "[init$1][$OVERRIDE_NAME] Install pnpm dependencies..."
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "pnpm install"
}

init() {
  doInit
}

initDev () {
  doInit "Dev"
}

build () {
  rm -rf build-css/
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
  docker-compose run -e SKIN_DIR=$SKIN_DIR -e SCSS_DIR=$SCSS_DIR -e DIST_DIR=$OVERRIDE_DIST --rm -u "$USER_UID:$GROUP_GID" node sh -c "pnpm run release:prepare"
  for dir in "${dirs[@]}"; do
    tmp=`echo $dir | sed 's/.\/skins\///'`
    docker-compose run -e SKIN_DIR=$SKIN_DIR -e SCSS_DIR=$SCSS_DIR -e DIST_DIR=$OVERRIDE_DIST -e SKIN=$tmp  --rm -u "$USER_UID:$GROUP_GID" node sh -c "pnpm run sass:build:release"
  done
  cp node_modules/ode-bootstrap/dist/version.txt $OVERRIDE_DIST/version.txt
  echo "$FINAL_MODNAME `date +'%d/%m/%Y %H:%M:%S'`" >> $OVERRIDE_DIST/version.txt
}

watch () {
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "pnpm run watch"
}

watchReact () {
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "pnpm run watch:react"
}

lint () {
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "pnpm run dev:lint"
}

lint-fix () {
  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "pnpm run dev:lint-fix"
}

publishNPM () {
  LOCAL_BRANCH=`echo $GIT_BRANCH | sed -e "s|origin/||g"`
  
  if [ "$OVERRIDE_NAME" != "default" ];
  then
    # rename npm package name to FINAL_MODNAME in package.json
    mv package.json package.json.orig
    sed "0,/ode-bootstrap-neo/{s|ode-bootstrap-neo|$FINAL_MODNAME|}" package.json.orig > package.json
  fi

  docker-compose run --rm -u "$USER_UID:$GROUP_GID" node sh -c "pnpm publish --no-git-checks --tag $LOCAL_BRANCH"
  status=$?

  if [ "$OVERRIDE_NAME" != "default" ];
  then
    mv package.json.orig package.json
  fi

  if [ $status != 0 ];
  then
    exit $status
  fi
}

archive() {
  echo "[archive][$OVERRIDE_NAME] Archiving dist folder..."
  tar cfzh ${FINAL_MODNAME}.tar.gz dist/*
}

publishNexus () {
  case "$MVN_MOD_VERSION" in
    *SNAPSHOT) nexusRepository='snapshots' ;;
    *)         nexusRepository='releases' ;;
  esac
  mvn deploy:deploy-file --batch-mode -DgroupId=$MVN_MOD_GROUPID -DartifactId=$FINAL_MODNAME -Dversion=$MVN_MOD_VERSION -Dpackaging=tar.gz -Dfile=${FINAL_MODNAME}.tar.gz -DrepositoryId=wse -Durl=https://maven.opendigitaleducation.com/nexus/content/repositories/$nexusRepository/
}

publishMavenLocal(){
  mvn install:install-file --batch-mode -DgroupId=$MVN_MOD_GROUPID -DartifactId=$FINAL_MODNAME -Dversion=$MVN_MOD_VERSION -Dpackaging=tar.gz -Dfile=${FINAL_MODNAME}.tar.gz
}

for param in "$@"
do
  echo "[$param][$OVERRIDE_NAME] Starting..."
  case $param in
    clean)
      clean
      ;;
    init)
      init
      ;;
    initDev)
      initDev
      ;;
    build)
      build
      ;;
    install)
      build && archive && publishMavenLocal
      ;;
    watch)
      watch
      ;;
    watchReact)
      watchReact
      ;;
    lint)
      lint
      ;;
    lint-fix)
      lint-fix
      ;;
    archive)
      archive
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
