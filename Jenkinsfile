pipeline {
    agent any

    tools {
        maven 'Maven-3'
        jdk 'JDK-17'
    }

    environment {
        APP_NAME = "boardgame-app"
        SCANNER_HOME = tool 'SonarQube-Scanner'
        APP_SERVER_IP = credentials('app-server-ip')
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo "🧹 Cleaning workspace..."
                cleanWs()
            }
        }

        stage('Git Checkout') {
            steps {
                echo "�� Checking out code..."
                git branch: 'main',
                    url: 'https://github.com/RiddheshRameshSutar/BoardGame/'
                sh 'ls -la'
            }
        }

        stage('Compile') {
            steps {
                echo "🔨 Compiling project..."
                dir('BoardGame') {
                    sh 'mvn clean compile'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                echo "🧪 Running unit tests..."
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
                echo "📊 Running SonarQube analysis..."
                withSonarQubeEnv('SonarQube') {
                    dir('BoardGame') {
                        sh '''
                            $SCANNER_HOME/bin/sonar-scanner \
                            -Dsonar.projectName=BoardGame \
                            -Dsonar.projectKey=BoardGame \
                            -Dsonar.java.binaries=target/classes
                        '''
                    }
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                echo "🔍 Running Trivy filesystem scan..."
                sh '''
                    trivy fs --format table -o trivy-fs-report.html . || true
                '''
            }
        }

        stage('Build Application') {
            steps {
                echo "📦 Building application..."
                dir('BoardGame') {
                    sh 'mvn clean package -DskipTests'
                    sh 'ls -la target/'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                script {
                    dir('BoardGame') {
                        sh '''
                            docker build -t ${APP_NAME}:${BUILD_NUMBER} .
                            docker tag ${APP_NAME}:${BUILD_NUMBER} ${APP_NAME}:latest
                        '''
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                echo "🔒 Scanning Docker image..."
                sh '''
                    trivy image --format table -o trivy-image-report.html ${APP_NAME}:latest
                '''
            }
        }

        stage('Deploy to Application Server') {
            steps {
                echo "🚀 Deploying to application server..."
                script {
                    sshagent(['app-server-ssh']) {
                        sh '''
                            echo "Copying JAR file to app server..."
                            scp -o StrictHostKeyChecking=no BoardGame/target/*.jar ubuntu@${APP_SERVER_IP}:/opt/boardgame-app/boardgame.jar
                            
                            echo "Deploying application on remote server..."
                            ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER_IP} << 'ENDSSH'
                                echo "🔧 Restarting boardgame service..."
                                sudo systemctl stop boardgame || true
                                sudo systemctl start boardgame
                                sleep 10
                                sudo systemctl status boardgame --no-pager
                            ENDSSH
                        '''
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                echo "💚 Performing health check..."
                script {
                    sh '''
                        echo "Checking application health..."
                        sleep 5
                        
                        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://${APP_SERVER_IP}:2255/ || echo "000")
                        
                        if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "302" ]; then
                            echo "✅ Application is healthy! HTTP Status: $RESPONSE"
                        else
                            echo "⚠ Warning: Application may still be starting (HTTP $RESPONSE)"
                        fi
                    '''
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo "📁 Archiving artifacts..."
                archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            echo "🏁 Pipeline execution completed!"

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
            echo '✅ Pipeline completed successfully!'
            echo "Application URL: http://${APP_SERVER_IP}:2255"
        }

        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
