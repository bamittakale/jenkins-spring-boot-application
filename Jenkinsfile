pipeline {
  
  agent any

  tools {
    maven 'Maven 3.9.3'
    jdk 'JDK8'
    dockerTool 'Docker 1.10.0'
  }

  environment {
    APP_NAME = "spring-boot-app-with-jenkins"
    IMAGE_NAME_WITH_TAG = "spring-boot-app-with-jenkins:${BUILD_ID}"
    BUILD_NUMBER = "${BUILD_ID}"
    APP_WAR_FILENAME="spring-boot-jenkins.war"
  }

  stages {

    stage ('Initialize') {
      steps {
        sh '''
            echo "PATH = ${PATH}"
            echo "M2_HOME = ${M2_HOME}"
        ''' 
      }
    }
    
    stage('Checkout') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            credentialsId: '2f6b6902-ed9e-470b-b2df-bf0668412c02', // Replace with the actual credential ID
            url: 'https://github.com/bamittakale/jenkins-spring-boot-application' // Replace with your Git repository URL
          ]]
        ])
      }
    }

    stage('Test') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Build Docker Image') {
      steps {
        // Build the Docker image using the Dockerfile
        sh "docker build -t ${env.IMAGE_NAME_WITH_TAG} ."
      }
    }
	
	  stage('Stop & Remove Previous Docker Container if it is running') {
      steps {
        script {
          def port = 8484 // Specify the port you want to check
          def containerRunning = sh(script: "docker ps -q --filter \"expose=${port}\"", returnStatus: true)
          if (containerRunning == 0) {
            echo "No container is running on port ${port}"
          } else {
            echo "A container is running on port ${port}"
            sh "docker container stop ${env.APP_NAME}"
            sh "docker container rm ${env.APP_NAME}"
          }
        }
      }
	  }

    stage('Deploy to Tomcat') {
      steps {
        script {
          docker.image("${env.IMAGE_NAME_WITH_TAG}").run("-p 8484:8484 -dit --name ${env.APP_NAME}")
        }
      }
    }
  }
  
}