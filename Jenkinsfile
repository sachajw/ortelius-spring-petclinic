pipeline {
    agent {
        label 'jenkins-jenkins-agent'
    }
    environment {
        DOCKERREPO = 'quay.io/pangarabbit/ortelius-spring-petclinic'
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0, 7)}"
        DISCORD = credentials('pangarabbit-discord-jenkins')
        JDK17_CONTAINER = 'agent-jdk17'
        KANIKO_CONTAINER = 'kaniko'
        PYTHON_CONTAINER = 'python39'
        DHUSER = 'admin'
        DHPASS = 'admin'
        DHORG = "PangaRabbit"
        DHPROJECT = "ortelius-spring-petclinic"
        DHURL = "https://console.deployhub.com"
    }

    stages {
        stage('Git Checkout') {
            steps {
                container("${JDK17_CONTAINER}") {
                    withCredentials([string(credentialsId: 'gh-sachajw-walle-secret-text', variable: 'GITHUB_PAT')]) {
                        sh '''
                            git config --global --add safe.directory ${WORKSPACE}
                            git clone https://${GITHUB_PAT}@github.com/sachajw/ortelius-spring-petclinic.git
                        '''
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                container("${KANIKO_CONTAINER}") {
                    script {
                        echo 'Building and pushing Docker image with Kaniko'
                        sh '''
                            /kaniko/executor \
                                --context . \
                                --dockerfile Dockerfile \
                                --destination ${DOCKERREPO}:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }

        stage('Capture SBOM') {
            steps {
                container("${PYTHON_CONTAINER}") {
                    script {
                        echo 'Installing Ortelius CLI and Capturing SBOM'
                        sh '''
                            pip install ortelius-cli
                            curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b .
                            ./syft packages ${DOCKERREPO}:${IMAGE_TAG} --scope all-layers -o cyclonedx-json > cyclonedx.json
                        '''
                    }
                }
            }
        }

        stage('Ortelius Update') {
            steps {
                container("${PYTHON_CONTAINER}") {
                    script {
                        echo 'Updating Ortelius Component with SBOM'
                        sh '''
                            dh --dhurl ${DHURL} --dhuser ${DHUSER} --dhpass ${DHPASS} updatecomp \
                                --rsp component.toml \
                                --deppkg "cyclonedx@${WORKSPACE}/cyclonedx.json"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Publishing Surefire HTML Report'
            publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: false,
                reportDir: 'target/site',
                reportFiles: 'surefire.html',
                reportName: 'Surefire Reports'
            ])
        }

        always {
            echo 'Sending Discord Notification'
            withCredentials([string(credentialsId: 'pangarabbit-discord-jenkins', variable: 'DISCORD')]) {
                discordSend description: """
                                Result: ${currentBuild.currentResult}
                                Service: ${env.JOB_NAME}
                                Build Number: [#${env.BUILD_NUMBER}](${env.BUILD_URL})
                                Branch: ${env.GIT_BRANCH}
                                Commit User: ${env.GIT_COMMIT_USER}
                                Duration: ${currentBuild.durationString}
                            """,
                            footer: 'Wall-E loves you!',
                            link: env.BUILD_URL,
                            result: currentBuild.currentResult,
                            title: env.JOB_NAME,
                            webhookURL: DISCORD
            }
        }
    }
}
