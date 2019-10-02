pipeline {
    agent {
        docker {
            image 'maven:alpine'
            args  '--env MAVEN_OPTS=-Xmx210m --env JAVA_OPTIONS=-Xmx300m -v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') { 
            steps {
                sh 'mvn test' 
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml' 
                }
            }
        }
        stage('Package') {
            steps {
                echo 'package'
            }
        }
    }
}
