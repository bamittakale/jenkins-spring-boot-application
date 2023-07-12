pipeline {
  
  agent any

  tools {
    maven 'Maven 3.9.3'
    jdk 'JDK8'
  }

  environment {
    APP_NAME = "spring-boot-app-with-jenkins"
    IMAGE_NAME_WITHOUT_TAG = "spring-boot-app-with-jenkins" 
    IMAGE_NAME_WITH_TAG = "spring-boot-app-with-jenkins:${BUILD_ID}"
    BUILD_NUMBER = "${BUILD_ID}"
    APP_WAR_FILENAME="spring-boot-with-jenkins-test.war"
    TOMCAT_IMAGE = "tomcat:9.0.46-jdk8-openjdk"
  }

  stages {

    stage('Check Image Existence') {
      steps {
        script {

          def imageName = "${env.TOMCAT_IMAGE}"
          def imageExists = false
          
          // Execute Docker command to check image existence
          def cmd = "docker image inspect ${imageName} > /dev/null 2>&1 && echo 'true' || echo 'false'"
          def result = bat(returnStdout: true, script: cmd)
          
          // Parse the command output to determine if image exists
          if (result.trim() == 'true') {
            imageExists = true
          }
          
          if (imageExists) {
            echo "The image ${imageName} already exists locally."
          } else { 
            echo "The image ${imageName} does not exist locally."
            bat "docker pull ${imageName}"
          }
        }
      }
    }

    // stage('Check Image Existence') {
    //   steps {
    //     script {
    //       def imageExist = bat(script: "docker images ${env.TOMCAT_IMAGE}", returnStatus: true)
    //       echo "imageExist: ${imageExist}"
    //       if (!imageExist) {
    //           bat "docker pull ${env.TOMCAT_IMAGE}"
    //       }
    //     }
    //   }
    // }

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

          def containerName = "${env.APP_NAME}"
          def containerStatus = 'not-found'

          // Execute Docker command to check container status
          def cmd = "docker inspect -f '{{.State.Status}}' ${containerName} > /dev/null 2>&1"
          def result = bat(returnStatus: true, script: cmd)

          if (result == 0) {
              // Container exists, retrieve its status
              containerStatus = sh(returnStdout: true, script: "docker inspect -f '{{.State.Status}}' ${containerName}").trim()
          } else {
              // Container does not exist
              containerStatus = 'not-found'
          }

          if (containerStatus == 'running') {
              echo "A container having name: ${containerName} is running"
              bat "docker container stop ${containerName}"
              bat "docker container rm ${containerName}"
              echo "A container having name: ${containerName} is stopped & removed successfully"
          } else if (containerStatus == 'exited') {
              echo "A container having name: ${containerName} is exist but it is stopped"
              bat "docker container rm ${containerName}"
              echo "A container having name: ${containerName} is removed successfully"
          } else {
              echo "A container having name: ${containerName} is does not exist."
          }
                               
          // def containerRunning = bat(script: "docker ps -f name=${env.APP_NAME}", returnStatus: true)
          // def containerStopped = bat(script: "docker ps -a -f name=${env.APP_NAME}", returnStatus: true)
          // echo "containerRunning: ${containerRunning}"
          // echo "containerStopped: ${containerStopped}"
          // if (containerRunning > 0) {
          //   echo "A container having name: ${env.APP_NAME} is running"
          //   bat "docker container stop ${env.APP_NAME}"
          //   bat "docker container rm ${env.APP_NAME}"
          //   echo "A container having name: ${env.APP_NAME} is stopped & removed successfully"
          // } else if (containerStopped > 0) {
          //   echo "A container having name: ${env.APP_NAME} is already stopped"
          //   bat "docker container rm ${env.APP_NAME}"
          //   echo "A container having name: ${env.APP_NAME} is removed successfully"
          // } else {
          //   echo "A container having name: ${env.APP_NAME} is running as well as stopped."
          // }

        }
      }
    }

    stage('Deploy to Tomcat') {
      steps {
        bat "docker container run -p 8484:8484 -dit --name ${env.APP_NAME} ${env.IMAGE_NAME_WITH_TAG}"
      }
    }

    stage('Post build action: removing the previous docker image') {
      steps {
        script {
          def previousBuild = currentBuild.getPreviousSuccessfulBuild()
          def previousBuildId = previousBuild?.getId()
          if (previousBuildId) {
            echo "Previous successful build ID: ${previousBuildId}"
            def imageWithTag = "${IMAGE_NAME_WITHOUT_TAG}:${previousBuildId}"
            bat "docker image rm ${imageWithTag}"
          }
        }
      }
    }
  }
}