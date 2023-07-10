pipeline {
  
  agent any

  environment {
    APP_NAME = "spring-boot-app-with-jenkins"
    IMAGE_NAME_WITH_TAG = "spring-boot-app-with-jenkins:${BUILD_ID}"
    BUILD_NUMBER = "${BUILD_ID}"
    APP_WAR_FILENAME="spring-boot-jenkins.war"
  }

  stages {
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
        sh 'Maven3/bin/mvn test'
      }
    }

    stage('Build') {
      steps {
        sh 'Maven3/bin/mvn clean package'

      }
    }

    stage('Build Docker Image') {
      steps {
        // Build the Docker image using the Dockerfile
        sh "docker build -t ${env.IMAGE_NAME_WITH_TAG} ."
      }
    }
	
	  stage('Stop & Remove Previous Docker Container') {
      steps {
        script {
          sh "docker container stop ${env.APP_NAME}"
          sh "docker container rm ${env.APP_NAME}"
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