@Library('jenkins-shared-library@master') _

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
                    command:
                      - /bin/sh
                      - -c
                      - >
                          git config --global --add safe.directory ${SAFE_DIR} && sleep 99d
                    tty: true
                  - name: python39
                    image: python:3.9-slim
                    command:
                      - /bin/sh
                      - -c
                      - >
                          git config --global --add safe.directory ${SAFE_DIR} && sleep 99d
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
        stage('Git Committer') {
            steps {
                container("${PYTHON_CONTAINER}") {
                    script {
                        sh "git config --global --add safe.directory ${WORKSPACE}"
                        env.GIT_COMMIT_USER = sh(
                            script: "git log -1 --pretty=format:'%an'",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage('Git Checkout') {
            steps {
                gitCheckout(
                    branch: 'master',
                    url: 'https://github.com/sachajw/ortelius-spring-petclinic.git'
                )
            }
        }


        stage('Surefire Report') {
            steps {
                container("${MAVEN_CONTAINER}") {
                    sh '''
                        ./mvnw clean install site surefire-report:report
                        tree
                    '''
                }
            }
        }

        stage('Ortelius') {
            steps {
                echo 'Ortelius'
                container("${PYTHON_CONTAINER}") {
                    sh '''
                        pip install ortelius-cli
                        rm -rf docker-hello-world-spring-boot
                        git clone https://github.com/dstar55/docker-hello-world-spring-boot
                        cd ortelius-spring-petclinic
                        dh envscript --envvars component.toml --envvars_sh ${WORKSPACE}/dhenv.sh
                    '''
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                container("${KANIKO_CONTAINER}") {
                    sh '''
                        echo "Building Docker image ${DOCKERREPO}:${IMAGE_TAG}"
                        docker build -t ${DOCKERREPO}:${IMAGE_TAG} .
                        docker push ${DOCKERREPO}:${IMAGE_TAG}
                    '''
                }
            }
        }
    }

    post {
        success {
            publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'target/site',
                reportFiles: 'surefire.html',
                reportName: 'Surefire Reports'
            ])
        }

        always {
            discordSend description: """
                Result: ${currentBuild.currentResult}
                Service: ${env.JOB_NAME}
                Build Number: [#${env.BUILD_NUMBER}](${env.BUILD_URL})
            """,
            webhookURL: DISCORD_WEBHOOK
        }
    }
}
