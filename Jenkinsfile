#!/usr/bin/env groovy

pipeline {
  agent any
    stages {
      stage('Init') {
        steps {
          checkout scm
          sh './build.sh clean init'
        }
      }
      stage('Build') {
        steps {
          sh './build.sh build'
        }
      }
      stage('Publish Archive') {
        steps {
          sh './build.sh publishNexus'
        }
      }
      stage('Publish NPM') {
        steps {
          configFileProvider([configFile(fileId: '.npmrc-ode-private', variable: 'NPMRC')]) {
            sh 'cp $NPMRC .npmrc'
            sh './build.sh publishNPM'
          }
        }
      }
    }
}

