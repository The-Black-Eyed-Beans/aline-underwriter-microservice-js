pipeline {
    agent any

    tools { 
        maven 'Maven 3.8.4' 
    }
    
    environment {
        AWS_ID = credentials("aws.id")
        AWS_DEFAULT_REGION = credentials("deployment.region")
        MICROSERVICE_NAME = "underwriter-microservice-js"
    }

    stages {
        stage ('Initialize') {
            steps {
                // Verify path variables for mvn
                sh '''
                    echo "Preparing to build, test and deploy ${MICROSERVICE_NAME}"
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                ''' 
            }
        }
        
        stage('Build') {
            steps {
                sh "git submodule init"
                sh "git submodule update"
                sh "mvn clean package -Dmaven.test.skip=true"
            }
        }
        //stage('Sonar Scan'){
        //    steps{
        //        withSonarQubeEnv('SonarQube-Server'){
        //            sh 'mvn verify sonar:sonar -Dmaven.test.failure.ignore=true'
        //        }
        //    }
        //}
        
        /*stage('Quality Gate'){
            steps{
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }*/
        
        stage('Push') {
            steps {
                script {
                    docker.withRegistry("https://${AWS_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com", "ecr:${AWS_DEFAULT_REGION}:jenkins.aws.credentials.js") {
                        
                        def image = docker.build("${MICROSERVICE_NAME}")
                        image.push('latest')
                    } 
                }  
            }
        }

        
        stage('Deploy'){
            steps {
                script {
                    docker.withRegistry("https://${AWS_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com", "ecr:${AWS_DEFAULT_REGION}:jenkins.aws.credentials.js") {
                        //sh "aws ecr get-login-password | docker login --username AWS --password-stdin 086620157175.dkr.ecr.us-west-1.amazonaws.com"

                        sh "aws ecs update-service --cluster ecs-cluster-js --service underwriter-service --force-new-deployment"    
                    } 
                }  
                
            }
        }

        stage('Cleanup') {
            steps {
                sh "docker image rm ${MICROSERVICE_NAME}:latest"
                sh 'docker image rm $AWS_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$MICROSERVICE_NAME'
                sh "docker image ls"
                sh "mvn clean"
            }
        }
    }
}
