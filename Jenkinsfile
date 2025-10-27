pipeline {
    agent any
    
    tools {
        maven 'Maven-3'
        jdk 'JDK-17'
    }
    
    environment {
        APP_NAME = "boardgame-app"
        SCANNER_HOME = tool 'SonarQube-Scanner'
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                echo "Cleaning workspace..."
                cleanWs()
            }
        }
        
        stage('Git Checkout') {
            steps {
                echo "Checking out code..."
                git branch: 'main', 
                    url: 'https://github.com/RiddheshRameshSutar/BoardGame.git'
                sh 'ls -la'
            }
        }
        
        stage('Compile') {
            steps {
                echo "Compiling project..."
                dir('BoardGame') {
                   sh 'mvn clean compile'
                }
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo "Running unit tests..."
                dir('BoardGame') {
                sh 'mvn test'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube analysis..."
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=BoardGame \
                        -Dsonar.projectKey=BoardGame \
                        -Dsonar.java.binaries=target/classes
                    '''
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                echo "Checking quality gate..."
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }
        
        stage('Trivy FS Scan') {
            steps {
                echo "Running Trivy filesystem scan..."
                sh '''
                    trivy fs --format table -o trivy-fs-report.html . || true
                    cat trivy-fs-report.html
                '''
            }
        }
        
        stage('Build Application') {
            steps {
                echo "Building application..."
                sh 'mvn clean package -DskipTests'
                sh 'ls -la target/'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                script {
                    sh '''
                        docker build -t ${APP_NAME}:${BUILD_NUMBER} . || echo "Docker build skipped"
                        docker tag ${APP_NAME}:${BUILD_NUMBER} ${APP_NAME}:latest || true
                    '''
                }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                echo "Scanning Docker image..."
                sh '''
                    trivy image --format table -o trivy-image-report.html ${APP_NAME}:latest || true
                '''
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                echo "Archiving artifacts..."
                archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
            }
        }
    }
    
    post {
        always {
            echo "Pipeline execution completed!"
            
            // Publish Trivy reports
            publishHTML([
                reportDir: '.',
                reportFiles: 'trivy-fs-report.html',
                reportName: 'Trivy FS Scan Report',
                keepAll: true,
                alwaysLinkToLastBuild: true,
                allowMissing: true
            ])
            
            publishHTML([
                reportDir: '.',
                reportFiles: 'trivy-image-report.html',
                reportName: 'Trivy Image Scan Report',
                keepAll: true,
                alwaysLinkToLastBuild: true,
                allowMissing: true
            ])
        }
        
        success {
            echo '✓ Pipeline completed successfully!'
        }
        
        failure {
            echo '✗ Pipeline failed!'
        }
    }
}
