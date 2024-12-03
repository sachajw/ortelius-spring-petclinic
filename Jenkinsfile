pipeline {
    agent {
        label 'jenkins-jenkins-agent'
    }
    environment {
        DOCKERREPO = 'quay.io/pangarabbit/ortelius-spring-petclinic'
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0, 7)}"
        SAFE_DIR = "${env.WORKSPACE}"
        DISCORD_WEBHOOK = credentials('pangarabbit-discord-jenkins')
        DEFAULT_CONTAINER = 'bbdefault'
        KANIKO_CONTAINER = 'kaniko'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Git Checkout') {
            steps {
                container("${DEFAULT_CONTAINER}") {
                    withCredentials([string(credentialsId: 'gh-sachajw-walle-secret-text', variable: 'GITHUB_PAT')]) {
                        sh "git config --global --add safe.directory ${env.WORKSPACE} && git clone https://${GITHUB_PAT}@github.com/sachajw/ortelius-jenkins-demo-app.git"
                    }
                }
            }
        }

        stage('Surefire Report') {
            steps {
                echo 'Generating Surefire Report'
                container("${DEFAULT_CONTAINER}") {
                    sh '''
                        #!/bin/bash
                        apt update -y && apt install openjdk-17-jdk -y
                        ./mvnw clean install site surefire-report:report
                        tree
                    '''
                }
            }
        }
    }
}
