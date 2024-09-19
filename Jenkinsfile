pipeline {
    agent any
    parameters {
        credentials(name: 'docker-hub', description: 'A user to login with', defaultValue: 'docker-hub', credentialType: 'Username with password', required: true )
        string(name: 'version', defaultValue: '1.0.2', description: 'version for pom.xml')
        string(name: 'user', defaultValue: 'tomcat', description: 'tomcat user to login')
        string(name: 'BUILD_TAG', defaultValue: 'java', description: 'build tag for war file')
    }
    // triggers {
    //     cron('H */4 * * 1-5')
    // }
    tools {
        jdk 'java'
        maven 'maven3'
    }
    environment {
        EMAIL_TO = 'sureshdevops986@gmail.com'
    }
    options {
        timestamps()
        buildDiscarder(logRotator(artifactDaysToKeepStr: '4', artifactNumToKeepStr: '3', daysToKeepStr: '3', numToKeepStr: '3'))
        timeout(time: 1, unit: 'MINUTES')
    }
    stages{
        stage('Build'){
            // when {
            //     branch 'master'
            //     // environment name: 'DEV', value: 'master'
            // }
            steps{
                 sh 'mvn clean compile install package'
                 archiveArtifacts artifacts: 'target/*.war', onlyIfSuccessful: true
            }
            post {
                always {
                    echo 'Test run completed'
                    junit allowEmptyResults: true, testResults: '**/target/*.xml'
                }
            }
        }
        stage('Sonarqube analysis'){
            steps{
                 withSonarQubeEnv('SonarQube'){
                 sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Upload War To Nexus'){
            steps{
                  nexusArtifactUploader artifacts: [
                      [
                          artifactId: 'simple-app',
                          classifier: '',
                          file: "target/simple-app-${params.version}.war",
                          type: 'war'
                      ]
                  ], 
                  credentialsId: 'nexus3', 
                  groupId: 'in.javahome', 
                  nexusUrl: 'localhost:8081', 
                  nexusVersion: 'nexus3', 
                  protocol: 'http', 
                  repository: 'sampleapp/', 
                  version: "${params.version}"
            }
        }
        stage('Download War'){
            steps('Download War From Nexus'){
                withCredentials([usernameColonPassword(credentialsId: 'nexus3', variable: 'NEXUS_CREDENTIALS')]) {
                    sh 'curl -u ${NEXUS_CREDENTIALS} -o simple-app "http://localhost:8081/repository/sampleapp/in/javahome/simple-app/1.0.2/simple-app-1.0.2.war"'   
                }
            }
        }
        stage('DeployToTomcat'){
            steps{
                withCredentials([string(credentialsId: 'tomcat_passwd', variable: 'tomcat')]) {
                    sh "curl -T target/simple-app-${version}.war 'http://${params.user}:${tomcat}@localhost:8082/manager/text/deploy?path=/java&update=true&tag=${BUILD_TAG}'"
                }
            }
        }
    }
}
