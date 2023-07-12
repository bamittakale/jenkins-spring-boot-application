pipeline {
  
  agent any

  tools {
    maven 'Maven 3.9.3'
    jdk 'JDK8'
  }

  environment {
    APP_NAME = "spring-boot-app-with-jenkins"
    IMAGE_NAME_WITH_TAG = "spring-boot-app-with-jenkins:${BUILD_ID}"
    BUILD_NUMBER = "${BUILD_ID}"
    APP_WAR_FILENAME="spring-boot-with-jenkins-test.war"
    tomcateImage = "tomcat:9.0.46-jdk8-openjdk"
  }

  stages {

    stage('Check Image Existence') {
      steps {
        script {
          def tomcat = "${tomcateImage}"
          if (!docker.image(tomcat).exists()) {
              bat "docker pull ${tomcat}"
          }
        }
      }
    }

    stage('Checkout') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            credentialsId: 'github-cred', // Replace with the actual credential ID
            url: 'https://github.com/bamittakale/jenkins-spring-boot-application' // Replace with your Git repository URL
          ]]
        ])
      }
    }

    stage('Test') {
      steps {
        bat 'mvn test'
      }
    }

    stage('Build') {
      steps {
        bat 'mvn clean package'
      }
    }

    stage('Build Docker Image') {
      steps {
        // Build the Docker image using the Dockerfile
        bat "docker build -t ${env.IMAGE_NAME_WITH_TAG} ."
      }
    }
	
	  stage('Stop & Remove Previous Docker Container if it is running') {
      steps {
        script {
          def containerRunning = bat(script: "docker ps -f name=${env.APP_NAME}", returnStatus: true)
          def containerStopped = bat(script: "docker ps -a -f name=${env.APP_NAME}", returnStatus: true)
          echo "containerRunning: ${containerRunning}"
          echo "containerStopped: ${containerStopped}"
          if (containerRunning > 0) {
            echo "A container having name: ${env.APP_NAME} is running"
            bat "docker container stop ${env.APP_NAME}"
            bat "docker container rm ${env.APP_NAME}"
            echo "A container having name: ${env.APP_NAME} is stopped & removed successfully"
          } else if (containerStopped > 0) {
            echo "A container having name: ${env.APP_NAME} is already stopped"
            bat "docker container rm ${env.APP_NAME}"
            echo "A container having name: ${env.APP_NAME} is removed successfully"
          } else {
            echo "A container having name: ${env.APP_NAME} is running as well as stopped."
          }
        }
      }
    }

    stage('Deploy to Tomcat') {
      steps {
        bat "docker container run -p 8484:8484 -dit --name ${env.APP_NAME} ${env.IMAGE_NAME_WITH_TAG}"
      }
    }
    
  }
}