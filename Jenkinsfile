pipeline {
    agent any

    environment {
        // הכנסתי לך כבר את המספרים שלך מהתמונות ששלחת
        AWS_ACCOUNT_ID = '992382545251'
        AWS_REGION = 'us-east-1'
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
                sh "docker build -t ${IMAGE_URI}:latest ."
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
                // הקסם: מריצים ישירות בלי SSH כי אנחנו כבר על השרת
                sh "docker stop calc-app || true"
                sh "docker rm calc-app || true"
                sh "docker run -d -p 5000:5000 --name calc-app ${IMAGE_URI}:latest"
            }
        }
    }
}
