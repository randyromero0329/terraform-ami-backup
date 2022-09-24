pipeline{
    agent any 
    //{
    //    label 'jenkins-paynamics'
    //}
    //tools {
    //    terraform 'terraform-11'
    //}
    //environment {
    //    service = "AMI Backup (Paynamics | Oregon)"
    //}
    stages{
        stage ('Push Notification: Start') {
            steps{
                echo '=========== Notification: Build Started ============'
                withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                            string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                    sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Hello, Terraform build started on ${service}.</b>"'
                }
            }
        }
        stage ('Git Checkout') {
            steps{
                echo '=========== GIT CHECKOUT ============'
                script {
                    try {
                        echo '=========== GIT CLONE ============'
                      //  git credentialsId: 'git-jenkins-key', url: 'git@gitlab.paynamics.net:terraform/aws-ec2-ami-paynamics-oregon-02.git'
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Gitlab checkout for ${service}, Successuful!</b>"'
                        }

                    } catch (Exception e) {
                        echo '=========== GIT Clone Failure ==========='
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Gitlab checkout for ${service}, Failed! Please Check. </b>"'
                        }
                        currentBuild.result = 'ABORTED'
                        error('Stopping early…')
                    }
                }
            }
        }
        stage ('Terraform Init') {
            steps{
                script {
                    try {
                        echo '=========== Terraform Init ============'
                     //   sh 'terraform init'
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Terraform Initialization for ${service}, Successful!</b>"'
                        }

                    } catch (Exception e) {
                        echo '=========== Terraform Init Failure ==========='
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Terraform Init for ${service} is Failed!</b>"'
                        }
                        currentBuild.result = 'ABORTED'
                        error('Stopping early…')
                    }
                }
            }
        }
        stage ('Terraform Plan') {
            steps{
                script {
                    try {
                        echo '=========== Terraform Plan ============'
                      //  sh 'terraform plan'
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Terraform Plan for ${service}, Successful!</b>"'
                        }

                    } catch (Exception e) {
                        echo '=========== Terraform Plan Failure ==========='
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Terraform Plan for ${service}, Failed!</b>"'
                        }
                        currentBuild.result = 'ABORTED'
                        error('Stopping early…')
                    }
                }
            }
        }
        stage ('Push Notification: Under Review') {
            steps {
                echo '===========Push Notification: Approval==========='
                withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                            string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                    sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Infrastructure changes for ${service} is under review! Please wait until the reviewer approve the changes</b>"'
                }
            }
        }
        stage ('Terraform Approval') {
            steps {
                script {
                    def proceed = true
                    try {
                        timeout(time: 3600, unit: 'SECONDS') {
                            input('Do you want to proceed for production deployment?')
                        }
                        sh 'echo "Deployment to production will resume"'
                    } catch (err) {
                        proceed = false
                        currentBuild.result = 'ABORTED'
                    }
                    if(proceed) {
                        echo '=========== PROCEED ==========='
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Infrastructure changes for ${service}, Approved!</b>"'
                        }
                    } else {
                        echo '=========== DONT PROCEED ==========='
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Infrastructure changes Aborted! Approval is needed for ${service}.</b>"'
                        }
                        currentBuild.result = 'ABORTED'
                        error('Stopping early…')
                    }
                }
            } 
        }
        stage ('Terraform Apply') {
            steps{
                script {
                    try {
                        echo '=========== Terraform Apply ============'
                      //  sh 'terraform apply --auto-approve'
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Terraform Apply for ${service}, Successful!</b>"'
                        }

                    } catch (Exception e) {
                        echo '=========== Terraform Apply Failure ==========='
                        withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                                string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                            sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Terraform Apply for ${service}, Failed!</b>"'
                        }
                        currentBuild.result = 'ABORTED'
                        error('Stopping early…')
                    }
                }
            }
        }
        stage ('Push Notification: End') {
            steps{
                echo '=========== Notification: Build Success ============'
                withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                            string(credentialsId: 'telegramChatID', variable: 'CHAT_ID')]) {
                    sh 'curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode="HTML" -d text="<b>Congratulations! Infrastructure changes fo ${service} is successfully Completed!</b>"'
                }
            }
        }
    }
}
