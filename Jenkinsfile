pipeline {
    environment {
        DOCKERREPO = "quay.io/pangarabbit/ortelius-spring-petclinic"
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0, 7)}"
        SAFE_DIR = "${env.WORKSPACE}"
        DISCORD_WEBHOOK = credentials('pangarabbit-discord-jenkins')
        PYTHON_CONTAINER = 'python39'
        MAVEN_CONTAINER = 'maven39'
        KANIKO_CONTAINER = 'kaniko'
    }

    agent {
        kubernetes {
            yaml """
              apiVersion: v1
              kind: Pod
              metadata:
                name: build-pod
              spec:
                containers:
                  - name: maven39
                    image: maven:3.9.9-amazoncorretto-8
                    tty: true
                  - name: python39
                    image: python:3.9-slim
                    tty: true
                  - name: kaniko
                    image: gcr.io/kaniko-project/executor:debug
                    command:
                    - /busybox/sh
                    tty: true
                restartPolicy: Always
            """
        }
    }

    stages {
        stage('Git Checkout') {
            steps {
                    withCredentials([string(credentialsId: 'gh-sachajw-walle-secret-text', variable: 'GITHUB_PAT')]) {
                    sh "git config --global --add safe.directory ${env.WORKSPACE} && git clone https://${GITHUB_PAT}@github.com/sachajw/ortelius-jenkins-demo-app.git"
              }
           }
        }
    }
}
