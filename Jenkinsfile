pipeline {
    agent {
        docker {
            image 'maven:alpine'
            args  '--env MAVEN_OPTS=-Xmx210m --env JAVA_OPTIONS=-Xmx300m'
        }
    }
    stages {
        stage('build') {
            steps {
                sh 'ls -al'
                sh 'mvn -B clean verify' 
                
            }
        }
        stage('package') {
            steps {
                echo 'package'
            }
        }
    }
}
