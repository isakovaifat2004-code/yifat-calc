pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '992382545251'
        AWS_REGION = 'us-east-1' 
        PROD_IP = '18.208.164.149' // הכתובת של השרת שלך (מהתמונה האחרונה)
        
        ECR_REPO = 'calculator-app'
        IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    }

    stages {
        stage('Login to AWS ECR') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
            }
        }

        stage('Build Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_URI}:latest ."
                }
            }
        }

        stage('Test App') {
            steps {
                sh "docker run --rm ${IMAGE_URI}:latest python -m unittest test_app.py"
            }
        }

        stage('Push to ECR') {
            steps {
                sh "docker push ${IMAGE_URI}:latest"
            }
        }

        stage('Deploy to Prod') {
            steps {
                sshagent(['prod-server-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${PROD_IP} '
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${IMAGE_URI}
                            docker pull ${IMAGE_URI}:latest
                            docker stop calc-app || true
                            docker rm calc-app || true
                            docker run -d -p 5000:5000 --name calc-app ${IMAGE_URI}:latest
                        '
                    """
                }
            }
        }
    }
}
