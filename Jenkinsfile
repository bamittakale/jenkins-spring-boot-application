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
  }

  stages {

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
          def port = 8484 // Specify the port you want to check
          def containerRunning = bat(script: "docker ps -q --filter \"expose=${port}\"", returnStatus: true)
          if (containerRunning == 0) {
            echo "No container is running on port ${port}"
          } else {
            echo "A container is running on port ${port}"
            bat "docker container stop ${env.APP_NAME}"
            bat "docker container rm ${env.APP_NAME}"
          }
        }
      }
	}

    stage('Deploy to Tomcat') {
      steps {
        bat "docker container run -p 8484:8484 -dit --name ${env.APP_NAME}"
      }
    }
  }
  
}