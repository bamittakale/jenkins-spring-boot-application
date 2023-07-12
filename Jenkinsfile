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
          def cmd = "docker images -qf reference=${imageName}"
          def oldImageID = bat(returnStdout:true , script: cmd).trim()
          def res = oldImageID.readLines().drop(1).join(" ")
          if (res.trim() != "") {
            echo "The image ${imageName} already exists locally."
          } else {
            echo "The image ${imageName} does not exist."
            bat "docker pull ${imageName}"
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
          def containerName = "${env.APP_NAME}"
          def cmd = "docker inspect -f {{.State.Status}} ${containerName}"
          def result = bat(returnStdout: true, script: cmd).trim()
          def res = result.readLines().drop(1).join("")
          echo "container status: ${res}"

          if (res == "running") {
            echo "A container having name: ${containerName} is running"
            bat "docker container stop ${containerName}"
            bat "docker container rm ${containerName}"
            echo "A container having name: ${containerName} is stopped & removed successfully"
          } else if (res == "exited") {
            echo "A container having name: ${containerName} is exited"
            bat "docker container rm ${containerName}"
            echo "A container having name: ${containerName} is removed successfully"
          } else {
            echo "A container having name: ${containerName} is does not exist."
          }
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