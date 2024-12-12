pipeline {
    agent {
        label 'jenkins-jenkins-agent'
    }
    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0, 7)}"
        DISCORD = credentials('pangarabbit-discord-jenkins')
        JDK17_CONTAINER = 'agent-jdk17'
        KANIKO_CONTAINER = 'kaniko'
        PYTHON_CONTAINER = 'python39'
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

        // stage('Surefire Report') {
        //     steps {
        //         container("${JDK17_CONTAINER}") {
        //             sh '''
        //                 ./mvnw clean install site surefire-report:report -Dcheckstyle.skip=true
        //                '''
        //         }
        //     }
        // }

        stage('Ortelius') {
            steps {
                container("${PYTHON_CONTAINER}") {
                    script {
                        sh '''
                            git config --global --add safe.directory /home/jenkins/agent/workspace/t_ortelius-spring-petclinic_main
                            pip install ortelius-cli
                            #dh envscript --envvars component.toml --envvars_sh ${WORKSPACE}/dhenv.sh
                            #dh --dhurl https://ortelius.pangarabbit.com --dhuser walle --dhpass Whimsical-Claim-Selective6 envscript --envvars component.toml --envvars_sh dhenv.sh
                            dh --dhurl https://console.deployhub.com --dhuser stella99 --dhpass 123456 envscript --envvars component.toml --envvars_sh dhenv.sh

                            . ${WORKSPACE}/dhenv.sh
                            curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b .
                            ./syft scan . --scope all-layers -o cyclonedx-json > ${WORKSPACE}/cyclonedx.json
                            cat ${WORKSPACE}/cyclonedx.json

                            . ${WORKSPACE}/dhenv.sh
                            dh updatecomp --rsp component.toml --deppkg "cyclonedx@${WORKSPACE}/cyclonedx.json"
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
