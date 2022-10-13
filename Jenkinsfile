#!/usr/bin/env groovy

pipeline {
  agent any
    stages {
      stage('Init') {
        steps {
          checkout scm
          script {
            if (params.OVERRIDE) {
              sh "./build.sh --override=\"${params.OVERRIDE}\" clean init"
            } else {
              sh './build.sh clean init'
            }
          }
        }
      }
      stage('Build') {
        steps {
          script {
            if (params.OVERRIDE) {
              sh "./build.sh --override=\"${params.OVERRIDE}\" build"
            } else {
              sh './build.sh build'
            }
          }
        }
      }
      stage('Archive') {
        steps {
          script {
            if (params.OVERRIDE) {
              sh "./build.sh --override=\"${params.OVERRIDE}\" archive"
            } else {
              sh './build.sh archive'
            }
          }
        }
      }
      stage('Publish Nexus') {
        steps {
          script {
            if (params.OVERRIDE) {
              sh "./build.sh --override=\"${params.OVERRIDE}\" publishNexus"
            } else {
              sh './build.sh publishNexus'
            }
          }
        }
      }
      stage('Publish NPM') {
        steps {
          script {
            configFileProvider([configFile(fileId: '.npmrc-infra-front', variable: 'NPMRC')]) {
              sh 'cp $NPMRC .npmrc'
              if (params.OVERRIDE) {
                sh "./build.sh --override=\"${params.OVERRIDE}\" publishNPM"
              } else {
                sh './build.sh publishNPM'
              }
            }
          }
        }
      }
    }
}

