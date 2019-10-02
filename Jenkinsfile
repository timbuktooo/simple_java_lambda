pipeline {
    agent none
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'maven:alpine'
                    args  '--env MAVEN_OPTS=-Xmx210m --env JAVA_OPTIONS=-Xmx300m -v /root/.m2:/root/.m2'
                }
            }
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') { 
            agent {
                docker {
                    image 'maven:alpine'
                    args  '--env MAVEN_OPTS=-Xmx210m --env JAVA_OPTIONS=-Xmx300m -v /root/.m2:/root/.m2'
                }
            }
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
            agent {
                docker {
                    image 'maven:alpine'
                    args  '--env MAVEN_OPTS=-Xmx210m --env JAVA_OPTIONS=-Xmx300m -v /root/.m2:/root/.m2'
                    }
                }
            steps {
                sh 'mvn package' 
            }
        }
        stage('Deploy') {
            agent none
            steps {
                sh 'aws --v' 
            }
        }
    }
}
